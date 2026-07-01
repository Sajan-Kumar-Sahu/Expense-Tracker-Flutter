class ReminderEntity {
  final String id;
  final String userId;
  final int reminderType;
  final int referenceModule;
  final String referenceId;
  final String title;
  final String message;
  final String scheduledDate;
  final int priority;
  final int status;
  final int repeatType;
  final int? repeatInterval;
  final bool isPushNotificationEnabled;
  final bool isInAppNotificationEnabled;
  final String? lastTriggeredAt;
  final String? nextTriggerAt;
  final String? completedAt;
  final String? expiresAt;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReminderEntity({
    required this.id,
    required this.userId,
    required this.reminderType,
    required this.referenceModule,
    required this.referenceId,
    required this.title,
    required this.message,
    required this.scheduledDate,
    required this.priority,
    required this.status,
    required this.repeatType,
    this.repeatInterval,
    required this.isPushNotificationEnabled,
    required this.isInAppNotificationEnabled,
    this.lastTriggeredAt,
    this.nextTriggerAt,
    this.completedAt,
    this.expiresAt,
    this.notes,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });
}
