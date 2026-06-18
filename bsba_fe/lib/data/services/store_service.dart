import 'package:project/data/models/staff_store.dart';
import 'package:project/data/services/api_client.dart';

class StoreService {
  StoreService(this._apiClient);

  final ApiClient _apiClient;

  Future<StaffStore> getStoreByStaffId(String staffId) async {
    final response = await _apiClient.get('/stores/staff/$staffId');
    final data = response['data'] as Map<String, dynamic>;
    return StaffStore.fromJson(data);
  }

  Future<StaffStore> updateStaffStore(StaffStoreUpdateRequest request) async {
    final response = await _apiClient.put('/stores/staff', request.toJson());
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return StaffStore.fromJson(data);
    }

    return StaffStore(
      id: request.storeId,
      storeName: request.storeName,
      description: request.description,
      address: request.address,
      coverLetterUrl: request.coverLetterUrl,
      phone: request.phone,
      email: request.email,
      openTime: request.openTime,
      closeTime: request.closeTime,
      totalCapacity: request.totalCapacity,
      chargeFee: request.chargeFee,
    );
  }
}
