import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../dependency_injection/injection.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationNotifier extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository) {
    loadNotifications();
  }

  bool isLoading = false;
  String? error;

  List<NotificationEntity> _notifications = [];
  int unreadCount = 0;

  List<NotificationEntity> get notifications => _notifications;

  Future<void> loadNotifications() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _notifications = await _repository.getAllNotifications();
      unreadCount = _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markRead(String id) async {
    try {
      await _repository.markRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !_notifications[index].isRead) {
        unreadCount = (unreadCount - 1).clamp(0, unreadCount);
      }
      await loadNotifications();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markClicked(String id) async {
    try {
      await _repository.markClicked(id);
      await loadNotifications();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllRead() async {
    try {
      await _repository.markAllRead();
      await loadNotifications();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
      _notifications.removeWhere((n) => n.id == id);
      unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void reset() {
    _notifications = [];
    unreadCount = 0;
    error = null;
    isLoading = false;
  }
}

final notificationProvider = ChangeNotifierProvider<NotificationNotifier>(
  (ref) => NotificationNotifier(locator<NotificationRepository>()),
);
