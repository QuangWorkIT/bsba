import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/boardgame_store/store_viewmodel.dart';
import 'package:project/ui/boardgame_store/widgets/profile_card.dart';
import 'package:project/ui/boardgame_store/widgets/store_feedback.dart';
import 'package:project/ui/boardgame_store/widgets/store_text_field.dart';
import 'package:project/ui/boardgame_store/widgets/store_validators.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StoreProfileViewModel>();

    return ProfileCard(
      icon: Icons.location_on_outlined,
      title: 'Location',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: StoreTextField(
                label: 'Address',
                controller: viewModel.addressController,
                validator: requiredField,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: FilledButton.tonalIcon(
                onPressed: () => showStoreAction(context, 'Map selector opened'),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Map'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/map/map_background.png',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const Icon(
                Icons.location_pin,
                color: StaffDashboardColors.primary,
                size: 48,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
