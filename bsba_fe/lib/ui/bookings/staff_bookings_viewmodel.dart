import 'package:flutter/material.dart';

import '../../data/models/staff_booking.dart';

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

/// Holds the (currently sample) bookings and the active filter for the staff
/// "Manage Bookings" screen.
class StaffBookingsViewModel extends ChangeNotifier {
  StaffBookingsViewModel() {
    _all = StaffBooking.sample();
  }

  List<StaffBooking> _all = const [];
  BookingFilter _filter = BookingFilter.all;

  BookingFilter get filter => _filter;

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
