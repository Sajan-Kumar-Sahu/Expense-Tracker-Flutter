import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/app_router.dart';
import '../providers/reminder_provider.dart';

class ReminderDashboardPage extends ConsumerStatefulWidget {
  const ReminderDashboardPage({super.key});

  @override
  ConsumerState<ReminderDashboardPage> createState() =>
      _ReminderDashboardPageState();
}

class _ReminderDashboardPageState
    extends ConsumerState<ReminderDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(reminderProvider).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(reminderProvider);
    final dashboard = provider.dashboard;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        title: Text(
          'Reminder Dashboard',
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                size: 20.r, color: theme.colorScheme.primary),
            onPressed: () => ref.read(reminderProvider).loadDashboard(),
          ),
        ],
      ),
      body: provider.isDashboardLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboard == null
              ? Center(
                  child: Text('No dashboard data',
                      style: theme.textTheme.bodyMedium),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(reminderProvider).loadDashboard(),
                  color: theme.colorScheme.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Overview grid ─────────────────────────────────
                        Text(
                          'Overview',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                          ),
                        ).animate().fadeIn(duration: 400.ms),
                        SizedBox(height: 12.h),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 1.6,
                          children: [
                            _StatCard(
                              label: 'Total',
                              value: dashboard.totalReminders,
                              icon: Icons.alarm_rounded,
                              color: theme.colorScheme.primary,
                              isDark: isDark,
                              index: 0,
                              onTap: () {
                                ref
                                    .read(reminderProvider)
                                    .applyFilter(ReminderFilter.all);
                                context.pop();
                              },
                            ),
                            _StatCard(
                              label: 'Pending',
                              value: dashboard.pendingCount,
                              icon: Icons.hourglass_empty_rounded,
                              color: const Color(0xFF3B82F6),
                              isDark: isDark,
                              index: 1,
                              onTap: () {
                                ref
                                    .read(reminderProvider)
                                    .applyFilter(ReminderFilter.pending);
                                context.pop();
                              },
                            ),
                            _StatCard(
                              label: 'Today',
                              value: dashboard.todayCount,
                              icon: Icons.today_rounded,
                              color: const Color(0xFF10B981),
                              isDark: isDark,
                              index: 2,
                              onTap: () {
                                ref
                                    .read(reminderProvider)
                                    .applyFilter(ReminderFilter.today);
                                context.pop();
                              },
                            ),
                            _StatCard(
                              label: 'Overdue',
                              value: dashboard.overdueCount,
                              icon: Icons.warning_amber_rounded,
                              color: const Color(0xFFEF4444),
                              isDark: isDark,
                              index: 3,
                              onTap: () {
                                ref
                                    .read(reminderProvider)
                                    .applyFilter(ReminderFilter.overdue);
                                context.pop();
                              },
                            ),
                            _StatCard(
                              label: 'Upcoming',
                              value: dashboard.upcomingThisWeekCount,
                              icon: Icons.upcoming_rounded,
                              color: const Color(0xFF8B5CF6),
                              isDark: isDark,
                              index: 4,
                              onTap: () {
                                ref
                                    .read(reminderProvider)
                                    .applyFilter(ReminderFilter.upcoming);
                                context.pop();
                              },
                            ),
                            _StatCard(
                              label: 'Critical',
                              value: dashboard.criticalCount,
                              icon: Icons.priority_high_rounded,
                              color: const Color(0xFFF59E0B),
                              isDark: isDark,
                              index: 5,
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // ── Notifications summary ─────────────────────────
                        Text(
                          'Notifications',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                        SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: () => context.push(AppRouter.notificationList),
                          child: Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44.r,
                                  height: 44.r,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.notifications_rounded,
                                    size: 22.r,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Unread Notifications',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '${dashboard.unreadNotificationsCount} unread',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14.r,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.3),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 400.ms),
                        SizedBox(height: 24.h),

                        // ── Completion summary ───────────────────────────
                        Text(
                          'Completion',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                          ),
                        ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Column(
                            children: [
                              _ProgressRow(
                                label: 'Completed',
                                count: dashboard.completedCount,
                                total: dashboard.totalReminders,
                                color: const Color(0xFF10B981),
                                isDark: isDark,
                              ),
                              SizedBox(height: 12.h),
                              _ProgressRow(
                                label: 'Pending',
                                count: dashboard.pendingCount,
                                total: dashboard.totalReminders,
                                color: const Color(0xFF3B82F6),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 450.ms, duration: 400.ms),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final int index;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 18.r, color: color),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(
              delay: Duration(milliseconds: 80 * index), duration: 400.ms)
          .scale(
              begin: const Offset(0.92, 0.92),
              end: const Offset(1, 1),
              delay: Duration(milliseconds: 80 * index),
              duration: 350.ms),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final bool isDark;

  const _ProgressRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '$count / $total',
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6.h,
            backgroundColor:
                isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
