class NotificationEntity {
  final String id;
  final String userId;
  final String reminderId;
  final String title;
  final String body;
  final int notificationType;
  final int referenceModule;
  final String referenceId;
  final bool isRead;
  final String? readAt;
  final bool isClicked;
  final String? clickedAt;
  final String sentAt;
  final int deliveryStatus;
  final String? actionUrl;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.reminderId,
    required this.title,
    required this.body,
    required this.notificationType,
    required this.referenceModule,
    required this.referenceId,
    required this.isRead,
    this.readAt,
    required this.isClicked,
    this.clickedAt,
    required this.sentAt,
    required this.deliveryStatus,
    this.actionUrl,
    required this.createdAt,
  });
}
