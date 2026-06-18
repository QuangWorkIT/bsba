import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/boardgame_store/store_viewmodel.dart';
import 'package:project/ui/boardgame_store/widgets/profile_card.dart';
import 'package:project/ui/boardgame_store/widgets/store_text_field.dart';
import 'package:project/ui/boardgame_store/widgets/store_validators.dart';

class ContactDetailsSection extends StatelessWidget {
  const ContactDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StoreProfileViewModel>();

    return ProfileCard(
      icon: Icons.contact_phone_outlined,
      title: 'Contact Details',
      children: [
        StoreTextField(
          label: 'Phone Number',
          controller: viewModel.phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.call_outlined,
          validator: requiredField,
        ),
        const SizedBox(height: 14),
        StoreTextField(
          label: 'Store Email',
          controller: viewModel.emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline_rounded,
          validator: emailField,
        ),
      ],
    );
  }
}
