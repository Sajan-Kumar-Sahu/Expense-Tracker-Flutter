import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../dependency_injection/injection.dart';
import '../../domain/entities/reminder_dashboard_entity.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminder_repository.dart';

enum ReminderFilter { all, pending, today, upcoming, overdue }

class ReminderNotifier extends ChangeNotifier {
  final ReminderRepository _repository;

  ReminderNotifier(this._repository) {
    loadReminders();
    loadDashboard();
  }

  bool isLoading = false;
  bool isDashboardLoading = false;
  String? error;

  List<ReminderEntity> _reminders = [];
  ReminderDashboardEntity? dashboard;
  ReminderFilter activeFilter = ReminderFilter.all;

  List<ReminderEntity> get reminders => _reminders;

  Future<void> loadReminders() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _reminders = await _fetchByFilter(activeFilter);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboard() async {
    isDashboardLoading = true;
    notifyListeners();
    try {
      dashboard = await _repository.getDashboard();
    } catch (_) {
    } finally {
      isDashboardLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyFilter(ReminderFilter filter) async {
    activeFilter = filter;
    await loadReminders();
  }

  Future<List<ReminderEntity>> _fetchByFilter(ReminderFilter filter) {
    switch (filter) {
      case ReminderFilter.pending:
        return _repository.getPendingReminders();
      case ReminderFilter.today:
        return _repository.getTodayReminders();
      case ReminderFilter.upcoming:
        return _repository.getUpcomingReminders();
      case ReminderFilter.overdue:
        return _repository.getOverdueReminders();
      case ReminderFilter.all:
        return _repository.getAllReminders();
    }
  }

  Future<bool> createReminder(Map<String, dynamic> data) async {
    try {
      await _repository.createReminder(data);
      await loadReminders();
      await loadDashboard();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateReminder(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateReminder(id, data);
      await loadReminders();
      await loadDashboard();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteReminder(String id) async {
    try {
      await _repository.deleteReminder(id);
      _reminders.removeWhere((r) => r.id == id);
      notifyListeners();
      await loadDashboard();
      return true;
    } catch (_) {
      return false;
    }
  }

  void reset() {
    _reminders = [];
    dashboard = null;
    error = null;
    isLoading = false;
    isDashboardLoading = false;
    activeFilter = ReminderFilter.all;
  }
}

final reminderProvider = ChangeNotifierProvider<ReminderNotifier>(
  (ref) => ReminderNotifier(locator<ReminderRepository>()),
);
