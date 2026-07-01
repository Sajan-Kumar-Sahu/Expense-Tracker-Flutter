import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/notification_entity.dart';

class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.index,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    DateTime? sentDt;
    try {
      sentDt = DateTime.parse(notification.sentAt);
    } catch (_) {}

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(Icons.delete_outline_rounded,
            color: const Color(0xFFEF4444), size: 22.r),
      ),
      confirmDismiss: (_) async {
        if (onDelete != null) {
          onDelete!();
          return true;
        }
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: notification.isRead
                ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                : (isDark
                    ? theme.colorScheme.primary.withValues(alpha: 0.08)
                    : theme.colorScheme.primary.withValues(alpha: 0.04)),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: notification.isRead
                  ? (isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0))
                  : theme.colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_rounded,
                        size: 18.r, color: theme.colorScheme.primary),
                  ),
                  if (!notification.isRead)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: notification.isRead
                            ? FontWeight.w500
                            : FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      sentDt != null
                          ? DateFormat('MMM d, y · h:mm a').format(sentDt)
                          : '-',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: 40 * index), duration: 350.ms)
        .slideY(
            begin: 0.05,
            end: 0,
            delay: Duration(milliseconds: 40 * index),
            duration: 350.ms);
  }
}
