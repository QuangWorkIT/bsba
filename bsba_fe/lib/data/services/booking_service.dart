import 'package:project/data/models/booking_summary.dart';
import 'package:project/data/models/booking.dart';
import 'package:project/data/models/pending_booking_lookup.dart';
import 'package:project/data/models/staff_booking.dart';
import 'package:project/data/services/api_client.dart';

class BookingService {
  final ApiClient _apiClient;

  BookingService(this._apiClient);

  /// Customer "My Bookings". Structure: { success: true, data: [...] }.
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

  Future<PendingBookingLookup?> lookupPendingBooking({
    required String userId,
    required String storeId,
  }) async {
    final query = Uri(queryParameters: {
      'userId': userId,
      'storeId': storeId,
    }).query;
    final response = await _apiClient.get('/bookings/lookup?$query');

    if (response['success'] == false) {
      throw ApiException(
        400,
        response['message'] as String? ?? 'Unable to lookup pending booking.',
      );
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) return null;

    return PendingBookingLookup.fromJson(data);
  }

  /// Staff "Manage Bookings". The caller's id + role come from the JWT, so we
  /// only pass the optional status filter (and a generous page size).
  /// Structure: { data: { items: [...], page, size, ... } }.
  Future<List<StaffBooking>> getStaffBookings({String? status, int size = 100}) async {
    final params = <String, String>{'size': '$size'};
    if (status != null) params['status'] = status;
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');

    final response = await _apiClient.get('/bookings/manage?$query');

    final items = response['data']['items'] as List<dynamic>;
    return items
        .map((json) => StaffBooking.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
