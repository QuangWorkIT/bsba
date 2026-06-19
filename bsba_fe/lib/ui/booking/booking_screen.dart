import 'package:flutter/material.dart';
import 'package:project/data/repositories/booking_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/booking_service.dart';
import 'package:provider/provider.dart';
import 'package:project/ui/booking/booking_viewmodel.dart';
import 'package:project/ui/booking/widgets/booking_content_state.dart';
import 'package:project/ui/booking/widgets/booking_header.dart';
import 'package:project/ui/booking/widgets/booking_tabs.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          BookingViewModel(BookingRepository(BookingService(ApiClient()))),
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
