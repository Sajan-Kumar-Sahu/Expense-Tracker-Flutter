import 'package:expense_tracker/features/worklog/domain/entities/work_log_entity.dart';
import 'package:expense_tracker/features/worklog/presentation/widgets/work_log_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// Summary card for a single WorkLog entry — mirrors TransactionCard style.
class WorkLogCard extends StatelessWidget {
  final WorkLogEntity workLog;
  final int index;
  final VoidCallback? onTap;

  const WorkLogCard({
    super.key,
    required this.workLog,
    required this.index,
    this.onTap,
  });

  static String _workTypeLabel(int wt) {
    switch (wt) {
      case 1:
        return 'Weekend';
      case 2:
        return 'Public Holiday';
      case 3:
        return 'On-Call';
      case 4:
        return 'Late Night';
      case 5:
        return 'Prod Support';
      case 6:
        return 'Client Support';
      case 7:
        return 'Emergency';
      default:
        return 'Other';
    }
  }

  static IconData _workTypeIcon(int wt) {
    switch (wt) {
      case 1:
        return Icons.weekend_rounded;
      case 2:
        return Icons.celebration_rounded;
      case 3:
        return Icons.support_agent_rounded;
      case 4:
        return Icons.nightlight_round;
      case 5:
        return Icons.terminal_rounded;
      case 6:
        return Icons.business_center_rounded;
      case 7:
        return Icons.warning_amber_rounded;
      default:
        return Icons.work_outline_rounded;
    }
  }

  static Color _workTypeColor(int wt) {
    switch (wt) {
      case 1:
        return const Color(0xFF10B981);
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
        return const Color(0xFF3B82F6);
      case 4:
        return const Color(0xFF8B5CF6);
      case 5:
        return const Color(0xFFEF4444);
      case 6:
        return const Color(0xFF06B6D4);
      case 7:
        return const Color(0xFFFF6B35);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _workTypeColor(workLog.workType);

    String formattedDate = workLog.workDate;
    try {
      final date = DateTime.parse(workLog.workDate);
      formattedDate = DateFormat('dd MMM yyyy').format(date);
    } catch (_) {}

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Work type icon
            Container(
              width: 46.r,
              height: 46.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                _workTypeIcon(workLog.workType),
                color: color,
                size: 22.r,
              ),
            ),
            SizedBox(width: 12.w),

            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workLog.taskTitle.isNotEmpty
                        ? workLog.taskTitle
                        : workLog.projectName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      WorkLogStatusBadge(status: workLog.status, small: true),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          '$formattedDate · ${workLog.projectName}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.45),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12.r,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.4),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${workLog.workedHours.toStringAsFixed(1)} hrs · ${_workTypeLabel(workLog.workType)}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (workLog.expectedAmount != null)
                  Text(
                    '₹${workLog.expectedAmount!.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: workLog.status == 5
                          ? const Color(0xFF8B5CF6)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                if (workLog.expectedAmount == null)
                  Text(
                    'No amount',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.35),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: index * 60 + 300), duration: 400.ms)
        .slideY(
          begin: 0.08,
          end: 0,
          delay: Duration(milliseconds: index * 60 + 300),
          duration: 400.ms,
        );
  }
}
