import 'package:project/data/models/staff_booking.dart';
import 'package:project/data/services/api_client.dart';

class BookingService {
  final ApiClient _apiClient;

  BookingService(this._apiClient);

  /// GET /api/v1/bookings — the caller's id + role come from the JWT, so we only
  /// pass the optional status filter (and a generous page size for the list).
  ///
  /// Response is wrapped: { data: { items: [...], page, size, ... } }.
  Future<List<StaffBooking>> getBookings({String? status, int size = 100}) async {
    final params = <String, String>{'size': '$size'};
    if (status != null) params['status'] = status;
    final query =
        params.entries.map((e) => '${e.key}=${e.value}').join('&');

    final response = await _apiClient.get('/bookings?$query');

    final items = response['data']['items'] as List<dynamic>;
    return items
        .map((json) => StaffBooking.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
