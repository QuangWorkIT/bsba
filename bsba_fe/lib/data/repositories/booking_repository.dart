import '../models/booking_summary.dart';
import '../services/booking_service.dart';

class BookingRepository {
  final BookingService _service;

  BookingRepository(this._service);

  Future<List<BookingSummary>> fetchUserBookings() async {
    return await _service.getBookings();
  }
}
