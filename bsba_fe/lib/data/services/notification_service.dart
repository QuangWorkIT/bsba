import 'package:project/data/models/notification.dart';
import 'package:project/data/services/api_client.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final jsonMap = await _apiClient.get('/notifications/$userId');

    final List<dynamic> data = jsonMap['data'];

    return data.map((item) => NotificationModel.fromJson(item)).toList();
  }
}
