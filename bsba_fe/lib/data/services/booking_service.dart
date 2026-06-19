import 'package:project/data/models/booking_summary.dart';
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
}
