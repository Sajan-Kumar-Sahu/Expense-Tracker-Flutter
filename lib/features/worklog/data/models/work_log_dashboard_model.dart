import 'package:expense_tracker/features/worklog/domain/entities/work_log_dashboard_entity.dart';

class WorkLogDashboardModel extends WorkLogDashboardEntity {
  const WorkLogDashboardModel({
    required super.totalEntries,
    required super.draftCount,
    required super.appliedCount,
    required super.approvedCount,
    required super.paidCount,
    required super.rejectedCount,
    required super.cancelledCount,
    required super.totalWorkedHours,
    required super.totalExpectedAmount,
    required super.totalReceivedAmount,
    required super.totalPendingAmount,
    required super.totalWeekendEntries,
    required super.totalHolidayEntries,
    required super.totalOnCallEntries,
    required super.totalProductionSupportEntries,
  });

  factory WorkLogDashboardModel.fromJson(Map<String, dynamic> json) {
    return WorkLogDashboardModel(
      totalEntries: json['totalEntries'] as int? ?? 0,
      draftCount: json['draftCount'] as int? ?? 0,
      appliedCount: json['appliedCount'] as int? ?? 0,
      approvedCount: json['approvedCount'] as int? ?? 0,
      paidCount: json['paidCount'] as int? ?? 0,
      rejectedCount: json['rejectedCount'] as int? ?? 0,
      cancelledCount: json['cancelledCount'] as int? ?? 0,
      totalWorkedHours: (json['totalWorkedHours'] as num?)?.toDouble() ?? 0.0,
      totalExpectedAmount:
          (json['totalExpectedAmount'] as num?)?.toDouble() ?? 0.0,
      totalReceivedAmount:
          (json['totalReceivedAmount'] as num?)?.toDouble() ?? 0.0,
      totalPendingAmount:
          (json['totalPendingAmount'] as num?)?.toDouble() ?? 0.0,
      totalWeekendEntries: json['totalWeekendEntries'] as int? ?? 0,
      totalHolidayEntries: json['totalHolidayEntries'] as int? ?? 0,
      totalOnCallEntries: json['totalOnCallEntries'] as int? ?? 0,
      totalProductionSupportEntries:
          json['totalProductionSupportEntries'] as int? ?? 0,
    );
  }
}
