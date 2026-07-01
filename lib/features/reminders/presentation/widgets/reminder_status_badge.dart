import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReminderStatusBadge extends StatelessWidget {
  final int status;
  final bool small;

  const ReminderStatusBadge({super.key, required this.status, this.small = false});

  static String label(int status) {
    switch (status) {
      case 1:
        return 'Pending';
      case 2:
        return 'Completed';
      case 3:
        return 'Cancelled';
      case 4:
        return 'Expired';
      default:
        return 'Unknown';
    }
  }

  static Color color(int status) {
    switch (status) {
      case 1:
        return const Color(0xFF3B82F6);
      case 2:
        return const Color(0xFF10B981);
      case 3:
        return const Color(0xFF64748B);
      case 4:
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = color(status);
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
      child: Text(
        label(status),
        style: TextStyle(
          fontSize: small ? 10.sp : 12.sp,
          fontWeight: FontWeight.w600,
          color: c,
        ),
      ),
    );
  }
}
