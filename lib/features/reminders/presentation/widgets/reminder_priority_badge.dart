import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReminderPriorityBadge extends StatelessWidget {
  final int priority;
  final bool small;

  const ReminderPriorityBadge({super.key, required this.priority, this.small = false});

  static String label(int priority) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      case 4:
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  static Color color(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFF10B981);
      case 2:
        return const Color(0xFF3B82F6);
      case 3:
        return const Color(0xFFF59E0B);
      case 4:
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  static IconData icon(int priority) {
    switch (priority) {
      case 1:
        return Icons.keyboard_arrow_down_rounded;
      case 2:
        return Icons.remove_rounded;
      case 3:
        return Icons.keyboard_arrow_up_rounded;
      case 4:
        return Icons.priority_high_rounded;
      default:
        return Icons.remove_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = color(priority);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6.w : 10.w,
        vertical: small ? 2.h : 4.h,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(small ? 6.r : 8.r),
        border: Border.all(color: c.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon(priority), size: small ? 10.r : 12.r, color: c),
          SizedBox(width: 2.w),
          Text(
            label(priority),
            style: TextStyle(
              fontSize: small ? 10.sp : 12.sp,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}
