import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/reminder_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ReminderRemoteDataSource _dataSource;

  NotificationRepositoryImpl(this._dataSource);

  @override
  Future<List<NotificationEntity>> getAllNotifications() => _dataSource.getAllNotifications();

  @override
  Future<List<NotificationEntity>> getUnreadNotifications() =>
      _dataSource.getUnreadNotifications();

  @override
  Future<List<NotificationEntity>> getNotificationHistory() =>
      _dataSource.getNotificationHistory();

  @override
  Future<NotificationEntity> getNotificationById(String id) =>
      _dataSource.getNotificationById(id);

  @override
  Future<void> markRead(String id) => _dataSource.markNotificationRead(id);

  @override
  Future<void> markClicked(String id) => _dataSource.markNotificationClicked(id);

  @override
  Future<void> markAllRead() => _dataSource.markAllNotificationsRead();

  @override
  Future<void> deleteNotification(String id) => _dataSource.deleteNotification(id);
}
