import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../providers/notification_provider.dart';
import '../widgets/notification_card.dart';

class NotificationListPage extends ConsumerStatefulWidget {
  const NotificationListPage({super.key});

  @override
  ConsumerState<NotificationListPage> createState() =>
      _NotificationListPageState();
}

class _NotificationListPageState
    extends ConsumerState<NotificationListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(notificationProvider).loadNotifications();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(notificationProvider).loadNotifications();
  }

  Future<void> _markAllRead() async {
    final success = await ref.read(notificationProvider).markAllRead();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'All notifications marked as read' : 'Failed'),
        backgroundColor: success
            ? const Color(0xFF10B981)
            : Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(notificationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              size: 18.r, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface),
            ),
            if (provider.unreadCount > 0)
              Text(
                '${provider.unreadCount} unread',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off_rounded,
                          size: 48.r,
                          color: theme.colorScheme.error
                              .withValues(alpha: 0.4)),
                      SizedBox(height: 16.h),
                      OutlinedButton.icon(
                        onPressed: _onRefresh,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: theme.colorScheme.primary,
                  child: provider.notifications.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: 120.h),
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 80.r,
                                    height: 80.r,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.notifications_off_rounded,
                                      size: 36.r,
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  Text(
                                    'No notifications yet',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Notifications will appear here',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.45),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding:
                              EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 40.h),
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          itemCount: provider.notifications.length,
                          itemBuilder: (context, index) {
                            final notification =
                                provider.notifications[index];
                            return NotificationCard(
                              notification: notification,
                              index: index,
                              onTap: () async {
                                if (!notification.isRead) {
                                  await ref
                                      .read(notificationProvider)
                                      .markRead(notification.id);
                                }
                              },
                              onDelete: () => ref
                                  .read(notificationProvider)
                                  .deleteNotification(notification.id),
                            );
                          },
                        ),
                ),
    );
  }
}
