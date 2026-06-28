class WorkLogEntity {
  final String id;
  final String userId;
  final String projectId;
  final String projectName;
  final String workDate; // ISO date string e.g. "2024-01-15"
  final int workType;
  final String startTime; // "HH:mm:ss"
  final String endTime; // "HH:mm:ss"
  final double workedHours;
  final String taskTitle;
  final String? description;
  final double? expectedAmount;
  final double? actualAmount;
  final int status;
  final String? referenceNumber;
  final String? appliedDate;
  final String? approvedDate;
  final String? paidDate;
  final String? paymentMonth;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const WorkLogEntity({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.projectName,
    required this.workDate,
    required this.workType,
    required this.startTime,
    required this.endTime,
    required this.workedHours,
    required this.taskTitle,
    this.description,
    this.expectedAmount,
    this.actualAmount,
    required this.status,
    this.referenceNumber,
    this.appliedDate,
    this.approvedDate,
    this.paidDate,
    this.paymentMonth,
    this.notes,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });
}
