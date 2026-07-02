import 'package:flutter/material.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

class ScanFloatingActionButton extends StatelessWidget {
  const ScanFloatingActionButton({
    super.key,
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
