import '../models/booking_summary.dart';
import '../models/staff_booking.dart';
import '../services/booking_service.dart';

class BookingRepository {
  final BookingService _service;

  BookingRepository(this._service);

  /// Customer "My Bookings".
  Future<List<BookingSummary>> fetchUserBookings() async {
    return await _service.getBookings();
  }

  /// Staff "Manage Bookings".
  Future<List<StaffBooking>> fetchStaffBookings({String? status}) {
    return _service.getStaffBookings(status: status);
  }
}
