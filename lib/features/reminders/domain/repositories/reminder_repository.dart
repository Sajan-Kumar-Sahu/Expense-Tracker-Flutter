import '../entities/reminder_dashboard_entity.dart';
import '../entities/reminder_entity.dart';

abstract class ReminderRepository {
  Future<List<ReminderEntity>> getAllReminders();
  Future<ReminderEntity> getReminderById(String id);
  Future<ReminderEntity> createReminder(Map<String, dynamic> data);
  Future<ReminderEntity> updateReminder(String id, Map<String, dynamic> data);
  Future<void> deleteReminder(String id);
  Future<List<ReminderEntity>> getPendingReminders();
  Future<List<ReminderEntity>> getTodayReminders();
  Future<List<ReminderEntity>> getUpcomingReminders();
  Future<List<ReminderEntity>> getOverdueReminders();
  Future<ReminderDashboardEntity> getDashboard();
}
