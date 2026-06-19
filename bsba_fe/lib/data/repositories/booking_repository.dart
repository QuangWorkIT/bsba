import '../models/staff_booking.dart';
import '../services/booking_service.dart';

class BookingRepository {
  final BookingService _service;

  BookingRepository(this._service);

  Future<List<StaffBooking>> fetchBookings({String? status}) {
    return _service.getBookings(status: status);
  }
}
