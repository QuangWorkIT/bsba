import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/boardgame_store/store_viewmodel.dart';
import 'package:project/ui/boardgame_store/widgets/helper_note.dart';
import 'package:project/ui/boardgame_store/widgets/profile_card.dart';
import 'package:project/ui/boardgame_store/widgets/store_text_field.dart';
import 'package:project/ui/boardgame_store/widgets/store_validators.dart';

class OperationsSection extends StatelessWidget {
  const OperationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StoreProfileViewModel>();

    return ProfileCard(
      icon: Icons.access_time_rounded,
      title: 'Operations',
      children: [
        Row(
          children: [
            Expanded(
              child: StoreTextField(
                label: 'Open Time',
                controller: viewModel.openTimeController,
                suffixIcon: Icons.expand_more_rounded,
                validator: requiredField,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StoreTextField(
                label: 'Close Time',
                controller: viewModel.closeTimeController,
                suffixIcon: Icons.expand_more_rounded,
                validator: requiredField,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        StoreTextField(
          label: 'Total Capacity (People)',
          controller: viewModel.capacityController,
          keyboardType: TextInputType.number,
          suffixIcon: Icons.groups_2_outlined,
          validator: positiveNumber,
        ),
        const SizedBox(height: 14),
        StoreTextField(
          label: 'Charge Fee per Hour',
          controller: viewModel.chargeController,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.payments_outlined,
          validator: positiveNumber,
        ),
        const SizedBox(height: 14),
        const HelperNote(
          icon: Icons.lightbulb_outline_rounded,
          text:
              'Peak capacity helps our booking engine optimize table rotations.',
        ),
      ],
    );
  }
}
