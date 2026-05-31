import 'package:flutter/material.dart';
import 'package:project/ui/checkout/checkout_form_field.dart';

enum PaymentMethod { card, eWallet, bankTransfer, payAtCounter }

class PaymentMethodSection extends StatelessWidget {
  const PaymentMethodSection({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
    required this.cardNumberController,
    required this.expiryController,
    required this.cvcController,
  });

  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onMethodSelected;
  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvcController;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return _CheckoutSectionCard(
      title: 'Payment Method',
      icon: Icons.credit_card,
      iconColor: scheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PaymentOption(
            label: 'Credit/Debit Card',
            icon: Icons.credit_card_outlined,
            isSelected: selectedMethod == PaymentMethod.card,
            onTap: () => onMethodSelected(PaymentMethod.card),
          ),
          const SizedBox(height: 8),
          _PaymentOption(
            label: 'E-Wallet',
            icon: Icons.account_balance_wallet_outlined,
            isSelected: selectedMethod == PaymentMethod.eWallet,
            onTap: () => onMethodSelected(PaymentMethod.eWallet),
          ),
          const SizedBox(height: 8),
          _PaymentOption(
            label: 'Bank Transfer',
            icon: Icons.account_balance_outlined,
            isSelected: selectedMethod == PaymentMethod.bankTransfer,
            onTap: () => onMethodSelected(PaymentMethod.bankTransfer),
          ),
          const SizedBox(height: 8),
          _PaymentOption(
            label: 'Pay at Counter',
            icon: Icons.storefront_outlined,
            isSelected: selectedMethod == PaymentMethod.payAtCounter,
            onTap: () => onMethodSelected(PaymentMethod.payAtCounter),
          ),
          if (selectedMethod == PaymentMethod.card) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE0E2EB)),
            const SizedBox(height: 17),
            CheckoutFormField(
              label: 'Card Number',
              controller: cardNumberController,
              hintText: '0000 0000 0000 0000',
              keyboardType: TextInputType.number,
              prefixIcon: Icon(
                Icons.credit_card,
                size: 20,
                color: scheme.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CheckoutFormField(
                    label: 'Expiry Date',
                    controller: expiryController,
                    hintText: 'MM/YY',
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CheckoutFormField(
                    label: 'CVC',
                    controller: cvcController,
                    hintText: '123',
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  static const _borderColor = Color(0xFFC1C6D5);
  static const _fillColor = Color(0xFFF9F9FF);
  static const _selectedFill = Color(0xFFD6E3FF);
  static const _bodyTextColor = Color(0xFF414753);
  static const _selectedTextColor = Color(0xFF001B3E);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
          decoration: BoxDecoration(
            color: isSelected ? _selectedFill : _fillColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? scheme.primary : _borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? scheme.primary : _bodyTextColor,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? _selectedTextColor : _bodyTextColor,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  height: 1.43,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check_circle, color: scheme.primary, size: 20),
            ],
          ),
        ),
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
