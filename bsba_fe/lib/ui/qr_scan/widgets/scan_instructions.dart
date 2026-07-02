import 'package:flutter/material.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

class ScanInstructions extends StatelessWidget {
  const ScanInstructions({
    super.key,
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
