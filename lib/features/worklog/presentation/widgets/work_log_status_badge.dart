import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Color-coded status badge matching the existing UI design language.
class WorkLogStatusBadge extends StatelessWidget {
  final int status;
  final bool small;

  const WorkLogStatusBadge({
    super.key,
    required this.status,
    this.small = false,
  });

  static String label(int status) {
    switch (status) {
      case 1:
        return 'Draft';
      case 2:
        return 'Applied';
      case 3:
        return 'Approved';
      case 4:
        return 'Rejected';
      case 5:
        return 'Paid';
      case 6:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  static Color color(int status) {
    switch (status) {
      case 1:
        return const Color(0xFF64748B); // slate
      case 2:
        return const Color(0xFF3B82F6); // blue
      case 3:
        return const Color(0xFF10B981); // emerald
      case 4:
        return const Color(0xFFEF4444); // red
      case 5:
        return const Color(0xFF8B5CF6); // violet
      case 6:
        return const Color(0xFFF59E0B); // amber
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = color(status);
    final statusLabel = label(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6.w : 10.w,
        vertical: small ? 2.h : 4.h,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(small ? 6.r : 8.r),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        statusLabel,
        style: TextStyle(
          fontSize: small ? 10.sp : 12.sp,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }
}
