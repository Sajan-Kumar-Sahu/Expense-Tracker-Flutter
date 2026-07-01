import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Runs in a separate isolate — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  // FCM automatically shows a system notification for background/terminated messages
  // that contain a `notification` payload — no extra work needed here.
}

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'reminders_channel';
  static const _channelName = 'Reminders';
  static const _channelDescription = 'Reminder and notification alerts';

  static Future<void> initialize() async {
    // 1. Register the background handler
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    // 2. Request permission (Android 13+ / iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    // 3. Create the Android notification channel (required for Android 8+)
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Initialize flutter_local_notifications (for foreground display)
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );

    // 5. Show notifications when app is in the FOREGROUND
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['reminderId'] as String?,
      );
    });

    // 6. Keep FCM token fresh — send to backend whenever it rotates
    _messaging.onTokenRefresh.listen(_sendTokenToBackend);
  }

  /// Returns the current FCM device token. Call this after login and send
  /// the result to  PUT /api/users/device-token  { "deviceToken": token }.
  static Future<String?> getToken() => _messaging.getToken();

  static void _sendTokenToBackend(String token) {
    // TODO: call your API to persist the new token
    // locator<UserRepository>().updateDeviceToken(token);
  }
}
