import 'package:flutter/foundation.dart';
import 'package:project/data/repositories/booking_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckInLog {
  const CheckInLog({
    required this.bookingCode,
    required this.customerName,
    required this.checkedInAt,
  });

  final String bookingCode;
  final String customerName;
  final DateTime checkedInAt;
}

class QrScanFeedback {
  const QrScanFeedback({required this.message, required this.isError});

  final String message;
  final bool isError;
}

class QrScanViewModel extends ChangeNotifier {
  QrScanViewModel(this._bookingRepository);

  final BookingRepository _bookingRepository;
  bool _scannerActive = false;
  bool _isCheckingIn = false;
  bool _cameraAccessRequested = false;
  bool _disposed = false;
  String? _errorMessage;
  String? _successMessage;
  String? _lastDetectedCode;
  DateTime? _lastDetectedAt;
  final List<CheckInLog> _recentLogs = [];

  bool get scannerActive => _scannerActive;
  bool get isCheckingIn => _isCheckingIn;
  bool get cameraAccessRequested => _cameraAccessRequested;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<CheckInLog> get recentLogs => List.unmodifiable(_recentLogs);
  bool get isEmpty => _recentLogs.isEmpty;

  QrScanFeedback? consumeFeedback() {
    final message = _errorMessage ?? _successMessage;
    if (message == null) {
      return null;
    }

    final feedback = QrScanFeedback(
      message: message,
      isError: _errorMessage != null,
    );
    _errorMessage = null;
    _successMessage = null;
    return feedback;
  }

  Future<void> requestCameraAccess() async {
    if (_cameraAccessRequested) {
      return;
    }

    _cameraAccessRequested = true;
    final status = await Permission.camera.request();
    if (_disposed) {
      return;
    }

    _scannerActive = status.isGranted;
    _successMessage = status.isGranted ? 'Scanner is ready.' : null;
    _errorMessage = status.isGranted
        ? null
        : 'Camera permission is required to scan booking QR codes.';
    notifyListeners();
  }

  void toggleScanner() {
    if (!_cameraAccessRequested) {
      requestCameraAccess();
      return;
    }

    _scannerActive = !_scannerActive;
    _successMessage = _scannerActive ? 'Scanner resumed.' : 'Scanner paused.';
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> scanCurrentFrame() {
    _successMessage = null;
    _errorMessage = 'Point the camera at a booking QR code to scan.';
    notifyListeners();
    return Future<void>.value();
  }

  void reportScannerError(String message) {
    _scannerActive = false;
    _successMessage = null;
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> scanDetectedCode(String rawCode) async {
    if (!_scannerActive || _isCheckingIn) {
      return;
    }

    final bookingCode = rawCode.trim();
    final now = DateTime.now();
    final lastDetectedAt = _lastDetectedAt;
    if (_lastDetectedCode == bookingCode &&
        lastDetectedAt != null &&
        now.difference(lastDetectedAt) < const Duration(seconds: 3)) {
      return;
    }

    _lastDetectedCode = bookingCode;
    _lastDetectedAt = now;
    await checkInCode(bookingCode);
  }

  Future<void> checkInCode(String rawCode) async {
    final bookingCode = rawCode.trim();
    _successMessage = null;
    _errorMessage = null;

    if (bookingCode.isEmpty) {
      _errorMessage = 'Enter a booking code before checking in.';
      notifyListeners();
      return;
    }

    if (bookingCode.length < 6) {
      _errorMessage = 'Booking code must be at least 6 characters.';
      notifyListeners();
      return;
    }

    _isCheckingIn = true;
    notifyListeners();

    try {
      final booking = await _bookingRepository.checkInBooking(bookingCode);
      if (_disposed) {
        return;
      }

      _recentLogs.insert(
        0,
        CheckInLog(
          bookingCode: booking.qrCode.isNotEmpty ? booking.qrCode : bookingCode,
          customerName: booking.title,
          checkedInAt: DateTime.now(),
        ),
      );

      if (_recentLogs.length > 5) {
        _recentLogs.removeRange(5, _recentLogs.length);
      }

      _successMessage = 'Checked in ${booking.title}.';
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to check in booking. Please try again.';
    } finally {
      if (!_disposed) {
        _isCheckingIn = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
