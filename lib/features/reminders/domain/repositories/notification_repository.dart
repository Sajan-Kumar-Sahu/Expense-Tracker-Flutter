import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getAllNotifications();
  Future<List<NotificationEntity>> getUnreadNotifications();
  Future<List<NotificationEntity>> getNotificationHistory();
  Future<NotificationEntity> getNotificationById(String id);
  Future<void> markRead(String id);
  Future<void> markClicked(String id);
  Future<void> markAllRead();
  Future<void> deleteNotification(String id);
}
