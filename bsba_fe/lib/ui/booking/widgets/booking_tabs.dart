import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/booking/booking_viewmodel.dart';

class BookingTabs extends StatelessWidget {
  const BookingTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.select<BookingViewModel, BookingTab>(
      (viewModel) => viewModel.selectedTab,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: BookingTab.values
            .map((tab) {
              return Expanded(
                child: _BookingTabButton(
                  label: switch (tab) {
                    BookingTab.completed => 'Completed',
                    BookingTab.pending => 'Pending',
                    BookingTab.cancelled => 'Cancelled',
                  },
                  selected: selected == tab,
                  onPressed: () =>
                      context.read<BookingViewModel>().selectTab(tab),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _BookingTabButton extends StatelessWidget {
  const _BookingTabButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: selected ? 3 : 1,
              color: selected ? scheme.primary : scheme.outlineVariant,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
