import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/boardgame_store/store_viewmodel.dart';
import 'package:project/ui/boardgame_store/widgets/profile_card.dart';
import 'package:project/ui/boardgame_store/widgets/store_text_field.dart';
import 'package:project/ui/boardgame_store/widgets/store_validators.dart';

class BasicInformationSection extends StatelessWidget {
  const BasicInformationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StoreProfileViewModel>();

    return ProfileCard(
      icon: Icons.info_outline_rounded,
      title: 'Basic Information',
      children: [
        StoreTextField(
          label: 'Store Name',
          controller: viewModel.storeNameController,
          validator: storeNameField,
        ),
        const SizedBox(height: 14),
        StoreTextField(
          label: 'Description',
          controller: viewModel.descriptionController,
          maxLines: 5,
          validator: storeDescriptionField,
        ),
      ],
    );
  }
}
