import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/reminder_entity.dart';
import 'reminder_priority_badge.dart';
import 'reminder_status_badge.dart';

class ReminderCard extends StatelessWidget {
  final ReminderEntity reminder;
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.index,
    required this.onTap,
    this.onDelete,
  });

  static String _moduleLabel(int module) {
    switch (module) {
      case 1:
        return 'Work Log';
      case 2:
        return 'Settlement';
      case 3:
        return 'Transaction';
      case 4:
        return 'Bill';
      case 5:
        return 'Investment';
      case 6:
        return 'Subscription';
      case 7:
        return 'Insurance';
      case 8:
        return 'Goal';
      case 9:
        return 'Custom';
      default:
        return 'Other';
    }
  }

  static IconData _moduleIcon(int module) {
    switch (module) {
      case 1:
        return Icons.work_outline_rounded;
      case 2:
        return Icons.handshake_outlined;
      case 3:
        return Icons.receipt_long_rounded;
      case 4:
        return Icons.receipt_outlined;
      case 5:
        return Icons.trending_up_rounded;
      case 6:
        return Icons.subscriptions_outlined;
      case 7:
        return Icons.health_and_safety_outlined;
      case 8:
        return Icons.flag_outlined;
      default:
        return Icons.alarm_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    DateTime? scheduledDt;
    try {
      scheduledDt = DateTime.parse(reminder.scheduledDate);
    } catch (_) {}

    final isOverdue = scheduledDt != null &&
        scheduledDt.isBefore(DateTime.now()) &&
        reminder.status == 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isOverdue
                ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _moduleIcon(reminder.referenceModule),
                size: 20.r,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reminder.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ReminderStatusBadge(status: reminder.status, small: true),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    reminder.message,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12.r,
                        color: isOverdue
                            ? const Color(0xFFEF4444)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        scheduledDt != null
                            ? DateFormat('MMM d, y').format(scheduledDt)
                            : '-',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isOverdue
                              ? const Color(0xFFEF4444)
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          _moduleLabel(reminder.referenceModule),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const Spacer(),
                      ReminderPriorityBadge(priority: reminder.priority, small: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: 50 * index), duration: 350.ms)
          .slideX(begin: 0.05, end: 0, delay: Duration(milliseconds: 50 * index), duration: 350.ms),
    );
  }
}
