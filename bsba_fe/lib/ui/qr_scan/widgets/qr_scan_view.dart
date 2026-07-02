import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:project/ui/qr_scan/qr_scan_viewmodel.dart';
import 'package:project/ui/qr_scan/widgets/manual_code_dialog.dart';
import 'package:project/ui/qr_scan/widgets/recent_check_ins.dart';
import 'package:project/ui/qr_scan/widgets/scan_floating_action_button.dart';
import 'package:project/ui/qr_scan/widgets/scan_instructions.dart';
import 'package:project/ui/qr_scan/widgets/scanner_canvas.dart';

class QrScanView extends StatelessWidget {
  const QrScanView({
    super.key,
    required this.viewModel,
    required this.scannerController,
    required this.onScannerBuilt,
    required this.onScannerException,
  });

  final QrScanViewModel viewModel;
  final MobileScannerController scannerController;
  final VoidCallback onScannerBuilt;
  final ValueChanged<MobileScannerException> onScannerException;

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
                      ScannerCanvas(
                        scannerController: scannerController,
                        scannerActive: viewModel.scannerActive,
                        isCheckingIn: viewModel.isCheckingIn,
                        onCodeDetected: viewModel.scanDetectedCode,
                        onScannerBuilt: onScannerBuilt,
                        onScannerException: onScannerException,
                      ),
                      const SizedBox(height: 32),
                      ScanInstructions(
                        isCheckingIn: viewModel.isCheckingIn,
                        scannerActive: viewModel.scannerActive,
                        onManualEntry: () =>
                            _showManualEntryDialog(context, viewModel),
                        onToggleScanner: viewModel.toggleScanner,
                      ),
                      const SizedBox(height: 32),
                      RecentCheckIns(
                        isEmpty: viewModel.isEmpty,
                        logs: viewModel.recentLogs,
                      ),
                    ],
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: ScanFloatingActionButton(
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
      builder: (_) => const ManualCodeDialog(),
    );

    if (code != null && code.isNotEmpty && context.mounted) {
      await viewModel.checkInCode(code);
    }
  }
}
