import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/boardgame_store/store_viewmodel.dart';
import 'package:project/ui/boardgame_store/widgets/basic_information_section.dart';
import 'package:project/ui/boardgame_store/widgets/contact_details_section.dart';
import 'package:project/ui/boardgame_store/widgets/location_section.dart';
import 'package:project/ui/boardgame_store/widgets/operations_section.dart';
import 'package:project/ui/boardgame_store/widgets/save_changes_button.dart';
import 'package:project/ui/boardgame_store/widgets/store_media_section.dart';
import 'package:project/ui/boardgame_store/widgets/store_profile_title.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

class StoreProfileContent extends StatelessWidget {
  const StoreProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StoreProfileViewModel>();

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: switch (viewModel.status) {
            StoreProfileStatus.loading => const _StoreLoadingState(),
            StoreProfileStatus.unassigned => _StoreUnassignedState(
              message: viewModel.errorMessage,
            ),
            StoreProfileStatus.error => _StoreErrorState(
              message: viewModel.errorMessage,
            ),
            StoreProfileStatus.loaded ||
            StoreProfileStatus.adding => const _StoreProfileForm(),
          },
        ),
      ),
    );
  }
}

class _StoreProfileForm extends StatelessWidget {
  const _StoreProfileForm();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: context.read<StoreProfileViewModel>().formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
        children: const [
          StoreProfileTitle(),
          SizedBox(height: 20),
          StoreMediaSection(),
          SizedBox(height: 28),
          BasicInformationSection(),
          SizedBox(height: 18),
          OperationsSection(),
          SizedBox(height: 18),
          LocationSection(),
          SizedBox(height: 18),
          ContactDetailsSection(),
          SizedBox(height: 24),
          SaveChangesButton(),
        ],
      ),
    );
  }
}

class _StoreLoadingState extends StatelessWidget {
  const _StoreLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _StoreUnassignedState extends StatelessWidget {
  const _StoreUnassignedState({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 28),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: StaffDashboardColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  color: StaffDashboardColors.primary,
                  size: 34,
                ),
                const SizedBox(height: 14),
                const Text(
                  'No active store assigned',
                  style: TextStyle(
                    color: StaffDashboardColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (message != null && message!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    message!,
                    style: const TextStyle(
                      color: StaffDashboardColors.muted,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: context
                        .read<StoreProfileViewModel>()
                        .startAddingStore,
                    icon: const Icon(Icons.add_business_outlined, size: 18),
                    label: const Text('Add new store'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreErrorState extends StatelessWidget {
  const _StoreErrorState({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 28),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: StaffDashboardColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: StaffDashboardColors.accent,
                  size: 34,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Store profile unavailable',
                  style: TextStyle(
                    color: StaffDashboardColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message ?? 'Unable to load store profile. Please try again.',
                  style: const TextStyle(
                    color: StaffDashboardColors.muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.tonalIcon(
                    onPressed: context.read<StoreProfileViewModel>().loadStore,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Try again'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
