import 'package:flutter/material.dart';
import 'package:project/data/models/booking_summary.dart';
import 'package:project/data/repositories/booking_repository.dart';

enum BookingTab { upcoming, completed, cancelled }

enum BookingLoadState { loading, loaded, error }

class BookingViewModel extends ChangeNotifier {
  final BookingRepository _repository;

  BookingViewModel(this._repository) {
    fetchBookings();
  }

  BookingTab _selectedTab = BookingTab.upcoming;
  BookingLoadState _state = BookingLoadState.loading;
  String? _errorMessage;
  List<BookingSummary> _bookings = [];

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

  Future<void> fetchBookings() async {
    _state = BookingLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookings = await _repository.fetchUserBookings();
      _state = BookingLoadState.loaded;
    } catch (e) {
      _state = BookingLoadState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
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
