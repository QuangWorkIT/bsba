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
}
