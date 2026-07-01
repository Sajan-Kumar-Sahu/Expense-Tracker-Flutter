import '../../domain/entities/reminder_entity.dart';

class ReminderModel extends ReminderEntity {
  const ReminderModel({
    required super.id,
    required super.userId,
    required super.reminderType,
    required super.referenceModule,
    required super.referenceId,
    required super.title,
    required super.message,
    required super.scheduledDate,
    required super.priority,
    required super.status,
    required super.repeatType,
    super.repeatInterval,
    required super.isPushNotificationEnabled,
    required super.isInAppNotificationEnabled,
    super.lastTriggeredAt,
    super.nextTriggerAt,
    super.completedAt,
    super.expiresAt,
    super.notes,
    required super.isActive,
    required super.createdAt,
    super.updatedAt,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      reminderType: json['reminderType'] as int,
      referenceModule: json['referenceModule'] as int,
      referenceId: json['referenceId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      scheduledDate: json['scheduledDate'] as String,
      priority: json['priority'] as int,
      status: json['status'] as int,
      repeatType: json['repeatType'] as int,
      repeatInterval: json['repeatInterval'] as int?,
      isPushNotificationEnabled: json['isPushNotificationEnabled'] as bool,
      isInAppNotificationEnabled: json['isInAppNotificationEnabled'] as bool,
      lastTriggeredAt: json['lastTriggeredAt'] as String?,
      nextTriggerAt: json['nextTriggerAt'] as String?,
      completedAt: json['completedAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'reminderType': reminderType,
      'referenceModule': referenceModule,
      'referenceId': referenceId,
      'title': title,
      'message': message,
      'scheduledDate': scheduledDate,
      'priority': priority,
      'status': status,
      'repeatType': repeatType,
      'repeatInterval': repeatInterval,
      'isPushNotificationEnabled': isPushNotificationEnabled,
      'isInAppNotificationEnabled': isInAppNotificationEnabled,
      'lastTriggeredAt': lastTriggeredAt,
      'nextTriggerAt': nextTriggerAt,
      'completedAt': completedAt,
      'expiresAt': expiresAt,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
