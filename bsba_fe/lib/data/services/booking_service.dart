import 'package:project/data/models/booking_summary.dart';
import 'package:project/data/models/booking.dart';
import 'package:project/data/services/api_client.dart';

class BookingService {
  final ApiClient _apiClient;

  BookingService(this._apiClient);

  Future<List<BookingSummary>> getBookings() async {
    final response = await _apiClient.get('/bookings');

    // Structure: { success: true, data: [...], ... }
    final List<dynamic> data = response['data'];

    return data.map((json) => BookingSummary.fromJson(json)).toList();
  }

  Future<BookingSummary> createBooking(Booking request) async {
    final response = await _apiClient.post('/bookings', request.toJson());

    if (response['success'] == false) {
      throw ApiException(
        400,
        response['message'] as String? ?? 'Unable to create booking.',
      );
    }

    final data = response['data'] as Map<String, dynamic>;
    return BookingSummary.fromJson(data);
  }
}
