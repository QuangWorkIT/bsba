import 'package:project/data/models/notification.dart';
import 'package:project/data/services/notification_service.dart';

class NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepository({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService();

  Future<List<NotificationModel>> getNotifications(String userId) {
    return _notificationService.getNotifications(userId);
  }

  Future<List<NotificationModel>> markNotificationsAsRead(
    List<String> notificationIds,
  ) {
    return _notificationService.markNotificationsAsRead(notificationIds);
  }
}
