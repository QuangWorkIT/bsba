import 'package:flutter/material.dart';

import '../../data/models/staff_booking.dart';
import '../../data/repositories/booking_repository.dart';

/// The chips above the booking list. [all] shows everything, [upcoming] filters
/// by time, the rest filter by [BookingStatus].
enum BookingFilter { all, upcoming, pending, confirmed, completed, cancelled }

extension BookingFilterLabel on BookingFilter {
  String get label => switch (this) {
        BookingFilter.all => 'All',
        BookingFilter.upcoming => 'Upcoming',
        BookingFilter.pending => 'Pending',
        BookingFilter.confirmed => 'Confirmed',
        BookingFilter.completed => 'Completed',
        BookingFilter.cancelled => 'Cancelled',
      };
}

/// Loads the staff's bookings from the API and holds the active filter for the
/// "Manage Bookings" screen. Filtering is done client-side over the loaded list.
class StaffBookingsViewModel extends ChangeNotifier {
  final BookingRepository _repository;

  StaffBookingsViewModel(this._repository);

  List<StaffBooking> _all = const [];
  BookingFilter _filter = BookingFilter.all;
  bool _isLoading = false;
  String? _error;

  BookingFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => !_isLoading && _error == null && bookings.isEmpty;

  /// Initial REST load. Surfaces a friendly message on failure.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _all = await _repository.fetchStaffBookings();
    } catch (e) {
      _error = 'Failed to load bookings. Make sure the backend is running.';
      debugPrint('Error loading bookings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Bookings matching the active filter.
  List<StaffBooking> get bookings {
    return _all.where((b) {
      switch (_filter) {
        case BookingFilter.all:
          return true;
        case BookingFilter.upcoming:
          return b.when == BookingWhen.upcoming;
        case BookingFilter.pending:
          return b.status == BookingStatus.pending;
        case BookingFilter.confirmed:
          return b.status == BookingStatus.confirmed;
        case BookingFilter.completed:
          return b.status == BookingStatus.completed;
        case BookingFilter.cancelled:
          return b.status == BookingStatus.cancelled;
      }
    }).toList();
  }

  /// Confirmed bookings for today — drives the "Daily Overview" summary line.
  int get confirmedTodayCount => _all
      .where((b) =>
          b.when == BookingWhen.today && b.status == BookingStatus.confirmed)
      .length;

  void setFilter(BookingFilter filter) {
    if (filter == _filter) return;
    _filter = filter;
    notifyListeners();
  }
}
