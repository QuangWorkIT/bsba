import 'package:flutter/material.dart';
import 'package:project/ui/checkout/checkout_form_field.dart';

class BillingDetailsSection extends StatelessWidget {
  const BillingDetailsSection({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return _CheckoutSectionCard(
      title: 'Billing Details',
      icon: Icons.person_outline,
      iconColor: scheme.primary,
      child: Column(
        children: [
          CheckoutFormField(
            label: 'Full Name',
            controller: nameController,
          ),
          const SizedBox(height: 16),
          CheckoutFormField(
            label: 'Email Address',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          CheckoutFormField(
            label: 'Phone Number (Optional)',
            controller: phoneController,
            hintText: '+1 (555) 000-0000',
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}

class _CheckoutSectionCard extends StatelessWidget {
  const _CheckoutSectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  static const _borderColor = Color(0xFFEBEDF7);
  static const _titleColor = Color(0xFF181C22);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: _titleColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
