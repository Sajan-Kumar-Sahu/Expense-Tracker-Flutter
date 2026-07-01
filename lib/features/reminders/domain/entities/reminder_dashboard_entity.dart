class ReminderDashboardEntity {
  final int totalReminders;
  final int pendingCount;
  final int completedCount;
  final int overdueCount;
  final int todayCount;
  final int upcomingThisWeekCount;
  final int criticalCount;
  final int unreadNotificationsCount;

  const ReminderDashboardEntity({
    required this.totalReminders,
    required this.pendingCount,
    required this.completedCount,
    required this.overdueCount,
    required this.todayCount,
    required this.upcomingThisWeekCount,
    required this.criticalCount,
    required this.unreadNotificationsCount,
  });
}
