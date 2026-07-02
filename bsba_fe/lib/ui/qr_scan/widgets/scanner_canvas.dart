import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

class ScannerCanvas extends StatelessWidget {
  const ScannerCanvas({
    super.key,
    required this.scannerController,
    required this.scannerActive,
    required this.isCheckingIn,
    required this.onCodeDetected,
    required this.onScannerBuilt,
    required this.onScannerException,
  });

  final MobileScannerController scannerController;
  final bool scannerActive;
  final bool isCheckingIn;
  final ValueChanged<String> onCodeDetected;
  final VoidCallback onScannerBuilt;
  final ValueChanged<MobileScannerException> onScannerException;

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
                onScannerBuilt: onScannerBuilt,
                onScannerException: onScannerException,
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
    required this.onScannerBuilt,
    required this.onScannerException,
  });

  final MobileScannerController controller;
  final bool scannerActive;
  final bool isCheckingIn;
  final ValueChanged<String> onCodeDetected;
  final VoidCallback onScannerBuilt;
  final ValueChanged<MobileScannerException> onScannerException;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _ScannerAttachmentObserver(
          onAttached: onScannerBuilt,
          child: MobileScanner(
            controller: controller,
            fit: BoxFit.cover,
            useAppLifecycleState: false,
            errorBuilder: (context, error) {
              onScannerException(error);
              return _ScannerErrorPlaceholder(error: error);
            },
            onDetect: (capture) {
              debugPrint(
                '[Scanner] onDetect fired '
                'barcodes=${capture.barcodes.length} '
                'scannerActive=$scannerActive '
                'isCheckingIn=$isCheckingIn',
              );

              for (final barcode in capture.barcodes) {
                final code = barcode.rawValue;
                debugPrint(
                  '[Scanner] detected barcode '
                  'format=${barcode.format} '
                  'hasRawValue=${code != null && code.trim().isNotEmpty}',
                );
                if (code != null && code.trim().isNotEmpty) {
                  onCodeDetected(code);
                  return;
                }
              }
            },
          ),
        ),
        if (!scannerActive) const _PausedScannerArtwork(),
      ],
    );
  }
}

class _ScannerAttachmentObserver extends StatefulWidget {
  const _ScannerAttachmentObserver({
    required this.onAttached,
    required this.child,
  });

  final VoidCallback onAttached;
  final Widget child;

  @override
  State<_ScannerAttachmentObserver> createState() =>
      _ScannerAttachmentObserverState();
}

class _ScannerAttachmentObserverState
    extends State<_ScannerAttachmentObserver> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onAttached();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _PausedScannerArtwork extends StatelessWidget {
  const _PausedScannerArtwork();

  @override
  Widget build(BuildContext context) {
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
