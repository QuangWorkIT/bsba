import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:project/data/repositories/booking_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/booking_service.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';
import 'package:project/ui/qr_scan/qr_scan_viewmodel.dart';
import 'package:project/ui/qr_scan/widgets/qr_scan_view.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key, this.active = false});

  final bool active;

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with WidgetsBindingObserver {
  late final QrScanViewModel _viewModel;
  late final MobileScannerController _scannerController;
  bool _scannerWidgetAttached = false;
  bool _scannerOperationInFlight = false;
  bool _scannerOperationPending = false;
  bool _scannerStarting = false;
  bool _scannerRunning = false;
  bool _scannerStopping = false;
  bool _scannerDisposeRequested = false;
  bool _scannerDisposed = false;
  bool _appLifecycleResumed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewModel = QrScanViewModel(
      BookingRepository(BookingService(ApiClient())),
    );
    _scannerController = MobileScannerController(
      autoStart: false,
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.qrCode],
    );
    _viewModel.addListener(_handleViewModelChanged);
    _requestCameraIfActive();
    _syncScannerController('initState');
  }

  @override
  void didUpdateWidget(covariant QrScanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      _logScanner(
        'widget active changed from ${oldWidget.active} to ${widget.active}',
      );
      _syncScannerController('didUpdateWidget');
    }

    if (!oldWidget.active && widget.active) {
      _requestCameraIfActive();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _appLifecycleResumed = true;
        _logScanner('lifecycle resumed');
        _syncScannerController('lifecycle resumed');
        return;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _appLifecycleResumed = false;
        _logScanner('lifecycle paused');
        _syncScannerController('lifecycle paused');
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return QrScanView(
      viewModel: _viewModel,
      scannerController: _scannerController,
      onScannerBuilt: _handleScannerBuilt,
      onScannerException: _handleScannerException,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.removeListener(_handleViewModelChanged);
    _scannerDisposeRequested = true;
    unawaited(_disposeScannerController());
    _viewModel.dispose();
    super.dispose();
  }

  void _handleViewModelChanged() {
    if (!mounted) {
      return;
    }

    _syncScannerController('view model changed');
    _showFeedback();
  }

  void _handleScannerBuilt() {
    if (!mounted || _scannerWidgetAttached) {
      return;
    }

    _scannerWidgetAttached = true;
    _logScanner('MobileScanner widget attached after first frame');
    _syncScannerController('scanner widget attached');
  }

  void _handleScannerException(MobileScannerException error) {
    _logScanner('MobileScanner widget exception: $error');
  }

  bool get _scannerShouldRun {
    return mounted &&
        !_scannerDisposeRequested &&
        !_scannerDisposed &&
        _scannerWidgetAttached &&
        widget.active &&
        _appLifecycleResumed &&
        _viewModel.scannerActive;
  }

  void _syncScannerController(String reason) {
    _logScanner('sync requested ($reason)');
    if (_scannerOperationInFlight) {
      _scannerOperationPending = true;
      _logScanner('sync queued ($reason)');
      return;
    }

    unawaited(_applyScannerState(reason));
  }

  Future<void> _applyScannerState(String reason) async {
    _scannerOperationInFlight = true;
    _logScanner('sync begin ($reason)');

    try {
      while (!_scannerDisposeRequested && !_scannerDisposed) {
        _scannerOperationPending = false;
        final shouldRun = _scannerShouldRun;
        _logScanner('sync evaluate shouldRun=$shouldRun');

        if (shouldRun && !_scannerRunning) {
          await _startScannerController();
        } else if (!shouldRun && _scannerRunning) {
          await _stopScannerController();
        } else {
          _logScanner('sync no-op');
        }

        if (_scannerOperationPending || _scannerShouldRun != _scannerRunning) {
          _logScanner('sync loop continuing');
          continue;
        }
        break;
      }
    } catch (error, stackTrace) {
      debugPrint('[Scanner] operation error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _scannerOperationInFlight = false;
      _logScanner('sync end ($reason)');
      if (!_scannerDisposeRequested &&
          !_scannerDisposed &&
          (_scannerOperationPending || _scannerShouldRun != _scannerRunning)) {
        _scannerOperationPending = false;
        _syncScannerController('pending state after sync');
      }
    }
  }

  Future<void> _startScannerController() async {
    _logScanner('request start');
    if (_scannerDisposeRequested || _scannerDisposed || !mounted) {
      _logScanner('start skipped (disposed)');
      return;
    }

    if (_scannerRunning) {
      _logScanner('start skipped (already running)');
      return;
    }

    if (!_scannerShouldRun) {
      _logScanner('start skipped (not requested)');
      return;
    }

    _scannerStarting = true;
    _logScanner('start begin');
    try {
      await _scannerController.start();
      _scannerRunning = true;
      if (_scannerDisposeRequested || _scannerDisposed || !mounted) {
        _logScanner('start completed after dispose');
        return;
      }

      _logScanner('start success');
    } on MobileScannerException catch (error) {
      _scannerRunning = false;
      _logScanner('start failed: $error');
      if (!mounted || _scannerDisposeRequested || _scannerDisposed) {
        return;
      }

      _viewModel.reportScannerError(_scannerErrorMessage(error));
    } finally {
      _scannerStarting = false;
      _logScanner('start end');
    }
  }

  Future<void> _stopScannerController({bool force = false}) async {
    if (_scannerStopping) {
      _logScanner('stop skipped (already stopping)');
      return;
    }

    if (!force && !_scannerRunning && !_scannerStarting) {
      _logScanner('stop skipped (already stopped)');
      return;
    }

    _scannerStopping = true;
    _logScanner('stop begin');
    try {
      await _scannerController.stop();
      _scannerRunning = false;
      _logScanner('stop success');
    } on MobileScannerException catch (error) {
      _scannerRunning = false;
      _logScanner('stop failed: $error');
    } finally {
      _scannerStopping = false;
      _scannerStarting = false;
      _logScanner('stop end');
    }
  }

  Future<void> _disposeScannerController() async {
    _logScanner('dispose requested');
    while (_scannerOperationInFlight) {
      _scannerOperationPending = true;
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }

    try {
      _logScanner('dispose begin');
      await _stopScannerController(force: true);
      await _scannerController.dispose();
      _scannerDisposed = true;
      _scannerRunning = false;
      _scannerStarting = false;
      _scannerStopping = false;
      _logScanner('disposed');
    } catch (error, stackTrace) {
      debugPrint('[Scanner] dispose error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String _scannerErrorMessage(MobileScannerException error) {
    final message = error.toString();
    if (message.trim().isNotEmpty) {
      return message;
    }

    return 'Unable to start the camera scanner.';
  }

  void _requestCameraIfActive() {
    if (!widget.active || _viewModel.cameraAccessRequested) {
      _logScanner(
        'permission request skipped active=${widget.active} '
        'requested=${_viewModel.cameraAccessRequested}',
      );
      return;
    }

    _logScanner('permission request scheduled after frame');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _logScanner('permission request begin');
        _viewModel.requestCameraAccess();
      } else {
        debugPrint('[Scanner] permission request skipped because unmounted');
      }
    });
  }

  void _showFeedback() {
    if (!mounted) {
      return;
    }

    final feedback = _viewModel.consumeFeedback();
    if (feedback == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final theme = Theme.of(context);
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(feedback.message),
            backgroundColor: feedback.isError
                ? theme.colorScheme.error
                : StaffDashboardColors.primary,
          ),
        );
    });
  }

  void _logScanner(String message) {
    debugPrint(
      '[Scanner] $message '
      'shouldRun=$_scannerShouldRun '
      'widgetAttached=$_scannerWidgetAttached '
      'operationInFlight=$_scannerOperationInFlight '
      'operationPending=$_scannerOperationPending '
      'starting=$_scannerStarting '
      'running=$_scannerRunning '
      'stopping=$_scannerStopping '
      'disposeRequested=$_scannerDisposeRequested '
      'disposed=$_scannerDisposed '
      'mounted=$mounted '
      'widgetActive=${widget.active} '
      'lifecycleResumed=$_appLifecycleResumed '
      'viewModelActive=${_viewModel.scannerActive}',
    );
  }
}
