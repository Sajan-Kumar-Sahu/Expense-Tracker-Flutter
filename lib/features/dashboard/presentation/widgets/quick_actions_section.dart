import 'package:expense_tracker/core/navigation/providers/nav_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_router.dart';

class QuickActionsSection extends ConsumerWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          ),
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            _QuickActionCard(
              icon: Icons.add_circle_rounded,
              label: 'Add\nExpense',
              color: const Color(0xFFEF4444),
              bgColor: const Color(0xFFFEF2F2),
              darkBgColor: const Color(0xFF3B1414),
              delay: 0,
              onTap: () => context.push(AppRouter.addTransaction, extra: 2),
            ),
            SizedBox(width: 12.w),
            _QuickActionCard(
              icon: Icons.savings_rounded,
              label: 'Add\nIncome',
              color: const Color(0xFF10B981),
              bgColor: const Color(0xFFF0FDF4),
              darkBgColor: const Color(0xFF0D2B1E),
              delay: 80,
              onTap: () => context.push(AppRouter.addTransaction, extra: 1),
            ),
            SizedBox(width: 12.w),
            _QuickActionCard(
              icon: Icons.swap_horiz_rounded,
              label: 'Transfer\nMoney',
              color: const Color(0xFF6366F1),
              bgColor: const Color(0xFFEEF2FF),
              darkBgColor: const Color(0xFF1E1B40),
              delay: 160,
              onTap: () => context.push(AppRouter.addTransaction, extra: 3),
            ),
            SizedBox(width: 12.w),
            _QuickActionCard(
              icon: Icons.handshake_outlined,
              label: 'Settle\nDebts',
              color: const Color(0xFFF59E0B),
              bgColor: const Color(0xFFFFFBEB),
              darkBgColor: const Color(0xFF2D2008),
              delay: 240,
              onTap: () =>
                  ref.read(navProvider.notifier).state = 5,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final Color darkBgColor;
  final int delay;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.darkBgColor,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.93 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: isDark ? widget.darkBgColor : widget.bgColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 22.r),
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: widget.color,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(
              delay: Duration(milliseconds: widget.delay + 300),
              duration: 500.ms)
          .slideY(
              begin: 0.3,
              end: 0,
              delay: Duration(milliseconds: widget.delay + 300),
              duration: 500.ms),
    );
  }
}
