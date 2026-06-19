import 'package:flutter/material.dart';
import 'package:project/ui/boardgame_store/widgets/store_input_border.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

class StoreTextField extends StatelessWidget {
  const StoreTextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: StaffDashboardColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          validator: validator,
          style: TextStyle(
            color: readOnly
                ? StaffDashboardColors.muted
                : StaffDashboardColors.text,
            fontSize: maxLines > 1 ? 14 : 15,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly
                ? StaffDashboardColors.disabledField
                : StaffDashboardColors.background,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 18),
            suffixIcon: suffixIcon == null ? null : Icon(suffixIcon, size: 18),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),
            border: storeInputBorder(),
            enabledBorder: storeInputBorder(),
            focusedBorder: storeInputBorder(color: StaffDashboardColors.primary),
            errorBorder: storeInputBorder(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}
