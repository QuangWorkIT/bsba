import 'package:flutter/foundation.dart';
import 'package:project/data/models/booking_summary.dart';

enum BookingTab { upcoming, completed, cancelled }

enum BookingLoadState { loading, loaded, error }

class BookingViewModel extends ChangeNotifier {
  BookingTab _selectedTab = BookingTab.upcoming;
  BookingLoadState _state = BookingLoadState.loaded;
  String? _errorMessage;

  final List<BookingSummary> _bookings = const [
    BookingSummary(
      title: "The Dragon's Lair - VIP Room",
      location: 'Downtown Haven Plaza',
      date: 'Sat, Oct 28',
      time: '2:00 PM - 5:00 PM',
      players: '4 Players',
      total: r'$77.50',
      imageAsset: 'assets/images/booking/booking_room_dragon.png',
      status: BookingStatus.confirmed,
    ),
    BookingSummary(
      title: 'Cyber Command Station',
      location: 'North District Hub',
      date: 'Wed, Nov 01',
      time: '6:00 PM - 9:00 PM',
      players: '6 Players',
      total: r'$110.00',
      imageAsset: 'assets/images/booking/booking_room_cyber.png',
      status: BookingStatus.confirmed,
    ),
  ];

  BookingTab get selectedTab => _selectedTab;
  BookingLoadState get state => _state;
  String? get errorMessage => _errorMessage;

  List<BookingSummary> get visibleBookings {
    return _bookings
        .where((booking) {
          return switch (_selectedTab) {
            BookingTab.upcoming => booking.status == BookingStatus.confirmed,
            BookingTab.completed => booking.status == BookingStatus.completed,
            BookingTab.cancelled => booking.status == BookingStatus.cancelled,
          };
        })
        .toList(growable: false);
  }

  void selectTab(BookingTab tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  void retry() {
    _state = BookingLoadState.loaded;
    _errorMessage = null;
    notifyListeners();
  }
}
