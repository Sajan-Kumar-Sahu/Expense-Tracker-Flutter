import '../../domain/entities/reminder_dashboard_entity.dart';

class ReminderDashboardModel extends ReminderDashboardEntity {
  const ReminderDashboardModel({
    required super.totalReminders,
    required super.pendingCount,
    required super.completedCount,
    required super.overdueCount,
    required super.todayCount,
    required super.upcomingThisWeekCount,
    required super.criticalCount,
    required super.unreadNotificationsCount,
  });

  factory ReminderDashboardModel.fromJson(Map<String, dynamic> json) {
    return ReminderDashboardModel(
      totalReminders: json['totalReminders'] as int,
      pendingCount: json['pendingCount'] as int,
      completedCount: json['completedCount'] as int,
      overdueCount: json['overdueCount'] as int,
      todayCount: json['todayCount'] as int,
      upcomingThisWeekCount: json['upcomingThisWeekCount'] as int,
      criticalCount: json['criticalCount'] as int,
      unreadNotificationsCount: json['unreadNotificationsCount'] as int,
    );
  }
}
