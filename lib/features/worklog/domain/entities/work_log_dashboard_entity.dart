class WorkLogDashboardEntity {
  final int totalEntries;
  final int draftCount;
  final int appliedCount;
  final int approvedCount;
  final int paidCount;
  final int rejectedCount;
  final int cancelledCount;
  final double totalWorkedHours;
  final double totalExpectedAmount;
  final double totalReceivedAmount;
  final double totalPendingAmount;
  final int totalWeekendEntries;
  final int totalHolidayEntries;
  final int totalOnCallEntries;
  final int totalProductionSupportEntries;

  const WorkLogDashboardEntity({
    required this.totalEntries,
    required this.draftCount,
    required this.appliedCount,
    required this.approvedCount,
    required this.paidCount,
    required this.rejectedCount,
    required this.cancelledCount,
    required this.totalWorkedHours,
    required this.totalExpectedAmount,
    required this.totalReceivedAmount,
    required this.totalPendingAmount,
    required this.totalWeekendEntries,
    required this.totalHolidayEntries,
    required this.totalOnCallEntries,
    required this.totalProductionSupportEntries,
  });
}
