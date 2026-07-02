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
    if (_disposed || _cameraAccessRequested) {
      debugPrint(
        '[Scanner] permission request skipped '
        'disposed=$_disposed requested=$_cameraAccessRequested',
      );
      return;
    }

    _cameraAccessRequested = true;
    debugPrint('[Scanner] permission request started');
    final status = await Permission.camera.request();
    debugPrint(
      '[Scanner] permission request completed '
      'status=$status granted=${status.isGranted}',
    );
    if (_disposed) {
      debugPrint('[Scanner] permission result ignored because disposed');
      return;
    }

    _scannerActive = status.isGranted;
    _successMessage = status.isGranted ? 'Scanner is ready.' : null;
    _errorMessage = status.isGranted
        ? null
        : 'Camera permission is required to scan booking QR codes.';
    debugPrint(
      '[Scanner] permission state applied scannerActive=$_scannerActive',
    );
    notifyListeners();
  }

  void toggleScanner() {
    if (_disposed) {
      return;
    }

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
    if (_disposed) {
      return Future<void>.value();
    }

    debugPrint(
      '[Scanner] scan current frame requested; '
      'mobile_scanner detects automatically from the live camera stream.',
    );
    return Future<void>.value();
  }

  void reportScannerError(String message) {
    if (_disposed) {
      return;
    }

    debugPrint('[Scanner] scanner error reported to view model: $message');
    _scannerActive = false;
    _successMessage = null;
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> scanDetectedCode(String rawCode) async {
    if (_disposed) {
      debugPrint('[Scanner] detected code ignored because disposed');
      return;
    }

    if (!_scannerActive || _isCheckingIn) {
      debugPrint(
        '[Scanner] detected code ignored '
        'scannerActive=$_scannerActive isCheckingIn=$_isCheckingIn',
      );
      return;
    }

    final bookingCode = rawCode.trim();
    debugPrint(
      '[Scanner] detected code received '
      'isEmpty=${bookingCode.isEmpty} length=${bookingCode.length}',
    );
    final now = DateTime.now();
    final lastDetectedAt = _lastDetectedAt;
    if (_lastDetectedCode == bookingCode &&
        lastDetectedAt != null &&
        now.difference(lastDetectedAt) < const Duration(seconds: 3)) {
      debugPrint('[Scanner] detected code ignored as duplicate');
      return;
    }

    _lastDetectedCode = bookingCode;
    _lastDetectedAt = now;
    await checkInCode(bookingCode);
  }

  Future<void> checkInCode(String rawCode) async {
    if (_disposed) {
      return;
    }

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
