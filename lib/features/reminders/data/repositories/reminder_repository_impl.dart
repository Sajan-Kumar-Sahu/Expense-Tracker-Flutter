import '../../domain/entities/reminder_dashboard_entity.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_remote_datasource.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderRemoteDataSource _dataSource;

  ReminderRepositoryImpl(this._dataSource);

  @override
  Future<List<ReminderEntity>> getAllReminders() => _dataSource.getAllReminders();

  @override
  Future<ReminderEntity> getReminderById(String id) => _dataSource.getReminderById(id);

  @override
  Future<ReminderEntity> createReminder(Map<String, dynamic> data) =>
      _dataSource.createReminder(data);

  @override
  Future<ReminderEntity> updateReminder(String id, Map<String, dynamic> data) =>
      _dataSource.updateReminder(id, data);

  @override
  Future<void> deleteReminder(String id) => _dataSource.deleteReminder(id);

  @override
  Future<List<ReminderEntity>> getPendingReminders() => _dataSource.getPendingReminders();

  @override
  Future<List<ReminderEntity>> getTodayReminders() => _dataSource.getTodayReminders();

  @override
  Future<List<ReminderEntity>> getUpcomingReminders() => _dataSource.getUpcomingReminders();

  @override
  Future<List<ReminderEntity>> getOverdueReminders() => _dataSource.getOverdueReminders();

  @override
  Future<ReminderDashboardEntity> getDashboard() => _dataSource.getDashboard();
}
