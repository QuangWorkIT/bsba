import 'package:flutter/material.dart';
import 'package:project/data/repositories/booking_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/booking_service.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/booking/booking_viewmodel.dart';
import 'package:project/ui/booking/widgets/booking_content_state.dart';
import 'package:project/ui/booking/widgets/booking_header.dart';
import 'package:project/ui/booking/widgets/booking_tabs.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
    this.active = true,
    this.refreshTrigger = 0,
    this.initialTab = BookingTab.completed,
  });

  final bool active;
  final int refreshTrigger;
  final BookingTab initialTab;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late final BookingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingViewModel(
      BookingRepository(BookingService(ApiClient())),
      initialTab: widget.initialTab,
    );
  }

  @override
  void didUpdateWidget(covariant BookingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.active &&
        widget.refreshTrigger != oldWidget.refreshTrigger) {
      _viewModel.fetchBookings();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: const SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookingHeader(),
            BookingTabs(),
            Expanded(child: BookingContentState()),
          ],
        ),
      ),
    );
  }
}
