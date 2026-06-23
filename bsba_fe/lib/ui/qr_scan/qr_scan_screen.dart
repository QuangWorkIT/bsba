import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';
import 'package:project/ui/qr_scan/qr_scan_viewmodel.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key, this.active = false});

  final bool active;

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  late final QrScanViewModel _viewModel;
  late final MobileScannerController _scannerController;
  bool _scannerControllerRunning = false;

  @override
  void initState() {
    super.initState();
    _viewModel = QrScanViewModel();
    _scannerController = MobileScannerController(
      autoStart: false,
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.qrCode],
    );
    _viewModel.addListener(_handleViewModelChanged);
    _requestCameraIfActive();
  }

  @override
  void didUpdateWidget(covariant QrScanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) {
      _requestCameraIfActive();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _QrScanView(
      viewModel: _viewModel,
      scannerController: _scannerController,
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChanged);
    _viewModel.dispose();
    unawaited(_scannerController.dispose());
    super.dispose();
  }

  void _handleViewModelChanged() {
    _syncScannerController();
    _showFeedback();
  }

  void _syncScannerController() {
    final shouldRun = _viewModel.scannerActive;
    if (_scannerControllerRunning == shouldRun) {
      return;
    }

    _scannerControllerRunning = shouldRun;
    if (!shouldRun) {
      unawaited(_stopScannerController());
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(_startScannerController());
    });
  }

  Future<void> _startScannerController() async {
    try {
      await _scannerController.start();
    } on MobileScannerException catch (error) {
      _scannerControllerRunning = false;
      _viewModel.reportScannerError(_scannerErrorMessage(error));
    }
  }

  Future<void> _stopScannerController() async {
    try {
      await _scannerController.stop();
    } on MobileScannerException {
      _scannerControllerRunning = false;
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
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _viewModel.requestCameraAccess();
      }
    });
  }

  void _showFeedback() {
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
}

class _QrScanView extends StatelessWidget {
  const _QrScanView({required this.viewModel, required this.scannerController});

  final QrScanViewModel viewModel;
  final MobileScannerController scannerController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        return SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 112),
                    children: [
                      _ScannerCanvas(
                        scannerController: scannerController,
                        scannerActive: viewModel.scannerActive,
                        isCheckingIn: viewModel.isCheckingIn,
                        onCodeDetected: viewModel.scanDetectedCode,
                      ),
                      const SizedBox(height: 32),
                      _Instructions(
                        isCheckingIn: viewModel.isCheckingIn,
                        scannerActive: viewModel.scannerActive,
                        onManualEntry: () =>
                            _showManualEntryDialog(context, viewModel),
                        onToggleScanner: viewModel.toggleScanner,
                      ),
                      const SizedBox(height: 32),
                      _RecentCheckIns(
                        isEmpty: viewModel.isEmpty,
                        logs: viewModel.recentLogs,
                      ),
                    ],
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: _ScanFloatingActionButton(
                      isCheckingIn: viewModel.isCheckingIn,
                      onPressed: viewModel.isCheckingIn
                          ? null
                          : () => viewModel.scanCurrentFrame(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showManualEntryDialog(
    BuildContext context,
    QrScanViewModel viewModel,
  ) async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _ManualCodeDialog(),
    );

    if (code != null && code.isNotEmpty && context.mounted) {
      await viewModel.checkInCode(code);
    }
  }
}

class _ManualCodeDialog extends StatefulWidget {
  const _ManualCodeDialog();

  @override
  State<_ManualCodeDialog> createState() => _ManualCodeDialogState();
}

class _ManualCodeDialogState extends State<_ManualCodeDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Booking Code'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'Booking code',
            hintText: 'BN-2026-QR-1042',
          ),
          validator: (value) {
            final code = value?.trim() ?? '';
            if (code.isEmpty) {
              return 'Booking code is required.';
            }
            if (code.length < 6) {
              return 'Use at least 6 characters.';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Check in')),
      ],
    );
  }

  void _submit() {
    if (_submitted) {
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      _submitted = true;
      Navigator.of(context).pop(_controller.text.trim());
    }
  }
}

class _ScannerCanvas extends StatelessWidget {
  const _ScannerCanvas({
    required this.scannerController,
    required this.scannerActive,
    required this.isCheckingIn,
    required this.onCodeDetected,
  });

  final MobileScannerController scannerController;
  final bool scannerActive;
  final bool isCheckingIn;
  final ValueChanged<String> onCodeDetected;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _CameraFeedPreview(
                controller: scannerController,
                scannerActive: scannerActive,
                isCheckingIn: isCheckingIn,
                onCodeDetected: onCodeDetected,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(
                    alpha: scannerActive ? 0.18 : 0.52,
                  ),
                ),
              ),
              Center(
                child: SizedBox.square(
                  dimension: 288,
                  child: Stack(
                    children: [
                      const _ScannerCorner(alignment: Alignment.topLeft),
                      const _ScannerCorner(alignment: Alignment.topRight),
                      const _ScannerCorner(alignment: Alignment.bottomLeft),
                      const _ScannerCorner(alignment: Alignment.bottomRight),
                      if (scannerActive)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: isCheckingIn ? 142 : 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: StaffDashboardColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: StaffDashboardColors.primary
                                      .withValues(alpha: 0.85),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Center(
                  child: _ScannerStatusPill(
                    active: scannerActive,
                    isCheckingIn: isCheckingIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraFeedPreview extends StatelessWidget {
  const _CameraFeedPreview({
    required this.controller,
    required this.scannerActive,
    required this.isCheckingIn,
    required this.onCodeDetected,
  });

  final MobileScannerController controller;
  final bool scannerActive;
  final bool isCheckingIn;
  final ValueChanged<String> onCodeDetected;

  @override
  Widget build(BuildContext context) {
    if (scannerActive) {
      return MobileScanner(
        controller: controller,
        fit: BoxFit.cover,
        errorBuilder: (context, error) {
          return _ScannerErrorPlaceholder(error: error);
        },
        onDetect: (capture) {
          if (isCheckingIn) {
            return;
          }

          for (final barcode in capture.barcodes) {
            final code = barcode.rawValue;
            if (code != null && code.trim().isNotEmpty) {
              onCodeDetected(code);
              return;
            }
          }
        },
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                StaffDashboardColors.scannerBackgroundStart,
                StaffDashboardColors.scannerBackgroundMiddle,
                StaffDashboardColors.scannerBackgroundEnd,
              ],
            ),
          ),
        ),
        Positioned(
          top: 46,
          left: 28,
          right: 54,
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: StaffDashboardColors.scannerLight.withValues(alpha: 0.46),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: StaffDashboardColors.scannerLightGlow.withValues(
                    alpha: 0.42,
                  ),
                  blurRadius: 18,
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Transform.rotate(
            angle: -0.08,
            child: Container(
              width: 118,
              height: 158,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: StaffDashboardColors.scannerCard,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.34),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.qr_code_2_rounded,
                          size: 70,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 8,
                    width: 54,
                    decoration: BoxDecoration(
                      color: StaffDashboardColors.scannerCardLine,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerErrorPlaceholder extends StatelessWidget {
  const _ScannerErrorPlaceholder({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.videocam_off_rounded,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 14),
            const Text(
              'Camera scanner could not start.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  const _ScannerCorner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;

    return Align(
      alignment: alignment,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(
                    color: StaffDashboardColors.primary,
                    width: 4,
                  )
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(
                    color: StaffDashboardColors.primary,
                    width: 4,
                  )
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(
                    color: StaffDashboardColors.primary,
                    width: 4,
                  )
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(
                    color: StaffDashboardColors.primary,
                    width: 4,
                  )
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? const Radius.circular(12) : Radius.zero,
            topRight: isTop && !isLeft
                ? const Radius.circular(12)
                : Radius.zero,
            bottomLeft: !isTop && isLeft
                ? const Radius.circular(12)
                : Radius.zero,
            bottomRight: !isTop && !isLeft
                ? const Radius.circular(12)
                : Radius.zero,
          ),
        ),
      ),
    );
  }
}

class _ScannerStatusPill extends StatelessWidget {
  const _ScannerStatusPill({required this.active, required this.isCheckingIn});

  final bool active;
  final bool isCheckingIn;

  @override
  Widget build(BuildContext context) {
    final label = isCheckingIn
        ? 'CHECKING IN'
        : active
        ? 'SCANNER ACTIVE'
        : 'SCANNER PAUSED';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: active
                    ? StaffDashboardColors.primary
                    : StaffDashboardColors.border,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Instructions extends StatelessWidget {
  const _Instructions({
    required this.isCheckingIn,
    required this.scannerActive,
    required this.onManualEntry,
    required this.onToggleScanner,
  });

  final bool isCheckingIn;
  final bool scannerActive;
  final VoidCallback onManualEntry;
  final VoidCallback onToggleScanner;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Scan the customer's booking QR\ncode to check them in.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: StaffDashboardColors.text,
            fontSize: 18,
            height: 1.33,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Position the code within the frame to detect\nautomatically.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: StaffDashboardColors.muted,
            fontSize: 14,
            height: 1.42,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: isCheckingIn ? null : onManualEntry,
          child: const Text(
            'Enter Code Manually',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        TextButton.icon(
          onPressed: isCheckingIn ? null : onToggleScanner,
          icon: Icon(
            scannerActive
                ? Icons.pause_circle_outline
                : Icons.play_circle_outline,
          ),
          label: Text(scannerActive ? 'Pause Scanner' : 'Resume Scanner'),
        ),
      ],
    );
  }
}

class _RecentCheckIns extends StatelessWidget {
  const _RecentCheckIns({required this.isEmpty, required this.logs});

  final bool isEmpty;
  final List<CheckInLog> logs;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: StaffDashboardColors.disabledField,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaffDashboardColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Check-ins',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: StaffDashboardColors.text,
                          fontSize: 18,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        isEmpty ? 'No check-ins yet' : 'Last 5 minutes',
                        style: const TextStyle(
                          color: StaffDashboardColors.muted,
                          fontSize: 12,
                          height: 1.33,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: StaffDashboardColors.muted,
                ),
              ],
            ),
            if (!isEmpty) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: StaffDashboardColors.border),
              const SizedBox(height: 10),
              ListView.separated(
                itemCount: logs.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return _RecentCheckInRow(log: log);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentCheckInRow extends StatelessWidget {
  const _RecentCheckInRow({required this.log});

  final CheckInLog log;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: StaffDashboardColors.primary,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${log.customerName} - ${log.bookingCode}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: StaffDashboardColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          _formatTime(log.checkedInAt),
          style: const TextStyle(
            color: StaffDashboardColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ScanFloatingActionButton extends StatelessWidget {
  const _ScanFloatingActionButton({
    required this.isCheckingIn,
    required this.onPressed,
  });

  final bool isCheckingIn;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'qr-scan-action',
      backgroundColor: StaffDashboardColors.accent,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: onPressed,
      tooltip: 'Scan current frame',
      child: isCheckingIn
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.qr_code_scanner_rounded, size: 28),
    );
  }
}
