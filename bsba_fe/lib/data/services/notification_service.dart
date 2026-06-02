import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/data/models/notification.dart';

class NotificationService {
  final client = http.Client();

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final response = await client.get(
      Uri.parse("http://10.0.2.2:8080/api/notifications/$userId"),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }

    final Map<String, dynamic> jsonMap = jsonDecode(response.body);

    final List<dynamic> data = jsonMap['data'];

    return data.map((item) => NotificationModel.fromJson(item)).toList();
  }
}
