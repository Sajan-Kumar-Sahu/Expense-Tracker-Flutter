import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';
import '../models/reminder_dashboard_model.dart';
import '../models/reminder_model.dart';

abstract class ReminderRemoteDataSource {
  Future<List<ReminderModel>> getAllReminders();
  Future<ReminderModel> getReminderById(String id);
  Future<ReminderModel> createReminder(Map<String, dynamic> data);
  Future<ReminderModel> updateReminder(String id, Map<String, dynamic> data);
  Future<void> deleteReminder(String id);
  Future<List<ReminderModel>> getPendingReminders();
  Future<List<ReminderModel>> getTodayReminders();
  Future<List<ReminderModel>> getUpcomingReminders();
  Future<List<ReminderModel>> getOverdueReminders();
  Future<ReminderDashboardModel> getDashboard();

  Future<List<NotificationModel>> getAllNotifications();
  Future<List<NotificationModel>> getUnreadNotifications();
  Future<List<NotificationModel>> getNotificationHistory();
  Future<NotificationModel> getNotificationById(String id);
  Future<void> markNotificationRead(String id);
  Future<void> markNotificationClicked(String id);
  Future<void> markAllNotificationsRead();
  Future<void> deleteNotification(String id);
}

class ReminderRemoteDataSourceImpl implements ReminderRemoteDataSource {
  final ApiClient _client;

  ReminderRemoteDataSourceImpl(this._client);

  @override
  Future<List<ReminderModel>> getAllReminders() async {
    final response = await _client.get(ApiEndpoints.reminders);
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => ReminderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ReminderModel> getReminderById(String id) async {
    final response = await _client.get('${ApiEndpoints.reminders}/$id');
    return ReminderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ReminderModel> createReminder(Map<String, dynamic> data) async {
    final response = await _client.post(ApiEndpoints.reminders, data: data);
    return ReminderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ReminderModel> updateReminder(String id, Map<String, dynamic> data) async {
    final response = await _client.put('${ApiEndpoints.reminders}/$id', data: data);
    return ReminderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteReminder(String id) async {
    await _client.delete('${ApiEndpoints.reminders}/$id');
  }

  @override
  Future<List<ReminderModel>> getPendingReminders() async {
    final response = await _client.get('${ApiEndpoints.reminders}/pending');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => ReminderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ReminderModel>> getTodayReminders() async {
    final response = await _client.get('${ApiEndpoints.reminders}/today');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => ReminderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ReminderModel>> getUpcomingReminders() async {
    final response = await _client.get('${ApiEndpoints.reminders}/upcoming');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => ReminderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ReminderModel>> getOverdueReminders() async {
    final response = await _client.get('${ApiEndpoints.reminders}/overdue');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => ReminderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ReminderDashboardModel> getDashboard() async {
    final response = await _client.get('${ApiEndpoints.reminders}/dashboard');
    return ReminderDashboardModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    final response = await _client.get(ApiEndpoints.notifications);
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<NotificationModel>> getUnreadNotifications() async {
    final response = await _client.get('${ApiEndpoints.notifications}/unread');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<NotificationModel>> getNotificationHistory() async {
    final response = await _client.get('${ApiEndpoints.notifications}/history');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<NotificationModel> getNotificationById(String id) async {
    final response = await _client.get('${ApiEndpoints.notifications}/$id');
    return NotificationModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> markNotificationRead(String id) async {
    await _client.post('${ApiEndpoints.notifications}/$id/mark-read');
  }

  @override
  Future<void> markNotificationClicked(String id) async {
    await _client.post('${ApiEndpoints.notifications}/$id/mark-clicked');
  }

  @override
  Future<void> markAllNotificationsRead() async {
    await _client.post('${ApiEndpoints.notifications}/mark-all-read');
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _client.delete('${ApiEndpoints.notifications}/$id');
  }
}
