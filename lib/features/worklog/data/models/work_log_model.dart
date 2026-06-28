import 'package:expense_tracker/features/worklog/domain/entities/work_log_entity.dart';

class WorkLogModel extends WorkLogEntity {
  const WorkLogModel({
    required super.id,
    required super.userId,
    required super.projectId,
    required super.projectName,
    required super.workDate,
    required super.workType,
    required super.startTime,
    required super.endTime,
    required super.workedHours,
    required super.taskTitle,
    super.description,
    super.expectedAmount,
    super.actualAmount,
    required super.status,
    super.referenceNumber,
    super.appliedDate,
    super.approvedDate,
    super.paidDate,
    super.paymentMonth,
    super.notes,
    required super.isActive,
    required super.createdAt,
    super.updatedAt,
  });

  factory WorkLogModel.fromJson(Map<String, dynamic> json) {
    return WorkLogModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      workDate: json['workDate'] as String? ?? '',
      workType: (json['workType'] as num?)?.toInt() ?? 0,
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      workedHours: (json['workedHours'] as num).toDouble(),
      taskTitle: json['taskTitle'] as String? ?? '',
      description: json['description'] as String?,
      expectedAmount: json['expectedAmount'] != null
          ? (json['expectedAmount'] as num).toDouble()
          : null,
      actualAmount: json['actualAmount'] != null
          ? (json['actualAmount'] as num).toDouble()
          : null,
      status: json['status'] as int,
      referenceNumber: json['referenceNumber'] as String?,
      appliedDate: json['appliedDate'] as String?,
      approvedDate: json['approvedDate'] as String?,
      paidDate: json['paidDate'] as String?,
      paymentMonth: json['paymentMonth'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
