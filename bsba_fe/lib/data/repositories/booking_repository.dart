import '../models/booking_summary.dart';
import '../models/booking.dart';
import '../models/pending_booking_lookup.dart';
import '../models/staff_booking.dart';
import '../services/booking_service.dart';

class BookingRepository {
  final BookingService _service;

  BookingRepository(this._service);

  /// Customer "My Bookings".
  Future<List<BookingSummary>> fetchUserBookings() async {
    return await _service.getBookings();
  }

  Future<BookingSummary> createBooking(Booking request) async {
    return await _service.createBooking(request);
  }

  Future<List<PendingBookingLookup>> lookupPendingBooking({
    required String userId,
    required String storeId,
  }) async {
    return await _service.lookupPendingBooking(userId: userId, storeId: storeId);
  }

  /// Staff "Manage Bookings".
  Future<List<StaffBooking>> fetchStaffBookings({String? status}) {
    return _service.getStaffBookings(status: status);
  }
}
