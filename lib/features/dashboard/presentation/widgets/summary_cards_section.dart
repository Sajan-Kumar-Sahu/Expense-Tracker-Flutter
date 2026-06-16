import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../providers/dashboard_provider.dart';

class SummaryCardsSection extends ConsumerWidget {
  const SummaryCardsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return dashboardAsync.when(
      loading: () => _SummaryCardsSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (dashboard) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TotalBalanceCard(
            totalBalance: dashboard.totalBalance,
            totalIncome: dashboard.totalIncome,
            totalSpent: dashboard.totalSpent,
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 600.ms),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Income',
                  amount: dashboard.totalIncome,
                  icon: Icons.arrow_downward_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  delay: 200,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _SummaryCard(
                  label: 'Expenses',
                  amount: dashboard.totalSpent,
                  icon: Icons.arrow_upward_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  delay: 300,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _SummaryCard(
                  label: 'Savings',
                  amount: dashboard.totalSavings,
                  icon: Icons.savings_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  delay: 400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Total Balance Card ───────────────────────────────────────────────────────

class _TotalBalanceCard extends ConsumerWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalSpent;

  const _TotalBalanceCard({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isVisible = ref.watch(balanceVisibleProvider);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, const Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(
                'TOTAL BALANCE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              // Eye toggle button
              GestureDetector(
                onTap: () => ref
                    .read(balanceVisibleProvider.notifier)
                    .state = !isVisible,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    isVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    key: ValueKey(isVisible),
                    color: Colors.white.withValues(alpha: 0.75),
                    size: 18.r,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'June 2024',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Main balance amount
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: isVisible
                ? KeyedSubtree(
                    key: const ValueKey('visible'),
                    child: AnimatedCounter(
                      targetAmount: totalBalance,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  )
                : KeyedSubtree(
                    key: const ValueKey('hidden'),
                    child: Text(
                      '••••••••',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
          ),

          SizedBox(height: 4.h),
          Text(
            '+12.5% from last month',
            style: TextStyle(
              color: Colors.greenAccent.withValues(alpha: 0.9),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20.h),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          SizedBox(height: 16.h),

          // Income / Spent chips
          Row(
            children: [
              _BalanceStatChip(
                icon: Icons.arrow_downward_rounded,
                label: 'Income',
                amount: totalIncome,
                color: Colors.greenAccent,
              ),
              SizedBox(width: 32.w),
              _BalanceStatChip(
                icon: Icons.arrow_upward_rounded,
                label: 'Spent',
                amount: totalSpent,
                color: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Balance Stat Chip ────────────────────────────────────────────────────────

class _BalanceStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  const _BalanceStatChip({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 14.r),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 11.sp,
              ),
            ),
            AnimatedCounter(
              targetAmount: amount,
              duration: const Duration(milliseconds: 1600),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Small summary cards (Income / Expenses / Savings) ───────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final LinearGradient gradient;
  final int delay;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.gradient,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20.r),
          SizedBox(height: 8.h),
          AnimatedCounter(
            targetAmount: amount,
            duration: Duration(milliseconds: 1200 + delay),
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms)
        .slideY(
            begin: 0.3,
            end: 0,
            delay: Duration(milliseconds: delay),
            duration: 600.ms);
  }
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────

class _SummaryCardsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shimmerColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 160.h,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: List.generate(
            3,
            (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 12.w : 0),
                height: 90.h,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
