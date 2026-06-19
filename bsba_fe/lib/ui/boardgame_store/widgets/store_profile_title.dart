import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/boardgame_store/store_viewmodel.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';

class StoreProfileTitle extends StatelessWidget {
  const StoreProfileTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final isAddingStore = context.watch<StoreProfileViewModel>().isAddingStore;

    return Row(
      children: [
        Expanded(
          child: Text(
            isAddingStore ? 'Add Store Profile' : 'Edit Store Profile',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: StaffDashboardColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
