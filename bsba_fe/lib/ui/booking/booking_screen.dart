import 'package:flutter/material.dart';
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
      create: (_) => BookingViewModel(),
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
