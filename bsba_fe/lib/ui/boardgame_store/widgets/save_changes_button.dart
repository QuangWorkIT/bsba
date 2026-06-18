import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/boardgame_store/store_viewmodel.dart';

class SaveChangesButton extends StatelessWidget {
  const SaveChangesButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StoreProfileViewModel>();
    final idleLabel = viewModel.isAddingStore ? 'Create Store' : 'Save Changes';
    final busyLabel = viewModel.isAddingStore ? 'Creating...' : 'Saving...';

    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: viewModel.isSaving
            ? null
            : () async {
                final messenger = ScaffoldMessenger.of(context);
                final saved = await context
                    .read<StoreProfileViewModel>()
                    .save();
                if (!context.mounted || !saved) {
                  return;
                }
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      viewModel.isAddingStore
                          ? 'Store profile ready to create'
                          : 'Store profile saved',
                    ),
                  ),
                );
              },
        icon: viewModel.isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined, size: 18),
        label: Text(viewModel.isSaving ? busyLabel : idleLabel),
      ),
    );
  }
}
