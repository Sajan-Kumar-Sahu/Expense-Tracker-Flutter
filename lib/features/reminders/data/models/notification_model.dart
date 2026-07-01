import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.reminderId,
    required super.title,
    required super.body,
    required super.notificationType,
    required super.referenceModule,
    required super.referenceId,
    required super.isRead,
    super.readAt,
    required super.isClicked,
    super.clickedAt,
    required super.sentAt,
    required super.deliveryStatus,
    super.actionUrl,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      reminderId: json['reminderId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      notificationType: json['notificationType'] as int,
      referenceModule: json['referenceModule'] as int,
      referenceId: json['referenceId'] as String,
      isRead: json['isRead'] as bool,
      readAt: json['readAt'] as String?,
      isClicked: json['isClicked'] as bool,
      clickedAt: json['clickedAt'] as String?,
      sentAt: json['sentAt'] as String,
      deliveryStatus: json['deliveryStatus'] as int,
      actionUrl: json['actionUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
