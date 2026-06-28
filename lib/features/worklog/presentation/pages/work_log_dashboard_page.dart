import 'package:expense_tracker/features/worklog/presentation/providers/work_log_provider.dart';
import 'package:expense_tracker/features/worklog/presentation/widgets/work_log_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// WorkLog Dashboard screen with summary cards and status breakdown.
/// Mirrors the existing DashboardPage structure.
class WorkLogDashboardPage extends ConsumerStatefulWidget {
  const WorkLogDashboardPage({super.key});

  @override
  ConsumerState<WorkLogDashboardPage> createState() =>
      _WorkLogDashboardPageState();
}

class _WorkLogDashboardPageState extends ConsumerState<WorkLogDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) ref.read(workLogProvider).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(workLogProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dashboard = provider.dashboard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Log Dashboard'),
      ),
      body: provider.isDashboardLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboard == null
              ? _ErrorState(onRetry: () => provider.loadDashboard())
              : RefreshIndicator(
                  onRefresh: () => provider.loadDashboard(),
                  color: theme.colorScheme.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header card ─────────────────────────────────────
                        _GradientSummaryCard(
                          totalEntries: dashboard.totalEntries,
                          totalHours: dashboard.totalWorkedHours,
                          expectedAmount: dashboard.totalExpectedAmount,
                          receivedAmount: dashboard.totalReceivedAmount,
                          pendingAmount: dashboard.totalPendingAmount,
                        ).animate().fadeIn(duration: 400.ms).slideY(
                              begin: -0.1,
                              end: 0,
                              duration: 400.ms,
                            ),
                        SizedBox(height: 24.h),

                        // ── Status breakdown ─────────────────────────────────
                        _SectionLabel(label: 'Status Breakdown'),
                        SizedBox(height: 12.h),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 10.h,
                          childAspectRatio: 0.9,
                          children: [
                            _StatusCountCard(
                                status: 1,
                                count: dashboard.draftCount)
                                .animate()
                                .fadeIn(delay: 100.ms, duration: 400.ms),
                            _StatusCountCard(
                                status: 2,
                                count: dashboard.appliedCount)
                                .animate()
                                .fadeIn(delay: 150.ms, duration: 400.ms),
                            _StatusCountCard(
                                status: 3,
                                count: dashboard.approvedCount)
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 400.ms),
                            _StatusCountCard(
                                status: 5, count: dashboard.paidCount)
                                .animate()
                                .fadeIn(delay: 250.ms, duration: 400.ms),
                            _StatusCountCard(
                                status: 4,
                                count: dashboard.rejectedCount)
                                .animate()
                                .fadeIn(delay: 300.ms, duration: 400.ms),
                            _StatusCountCard(
                                status: 6,
                                count: dashboard.cancelledCount)
                                .animate()
                                .fadeIn(delay: 350.ms, duration: 400.ms),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // ── Work type breakdown ───────────────────────────────
                        _SectionLabel(label: 'Work Type Summary'),
                        SizedBox(height: 12.h),
                        _WorkTypeRow(
                          entries: [
                            (
                              label: 'Weekend',
                              count: dashboard.totalWeekendEntries,
                              icon: Icons.weekend_rounded,
                              color: const Color(0xFF10B981),
                            ),
                            (
                              label: 'Holiday',
                              count: dashboard.totalHolidayEntries,
                              icon: Icons.celebration_rounded,
                              color: const Color(0xFFF59E0B),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 400.ms),
                        SizedBox(height: 10.h),
                        _WorkTypeRow(
                          entries: [
                            (
                              label: 'On-Call',
                              count: dashboard.totalOnCallEntries,
                              icon: Icons.support_agent_rounded,
                              color: const Color(0xFF3B82F6),
                            ),
                            (
                              label: 'Prod.Support',
                              count: dashboard.totalProductionSupportEntries,
                              icon: Icons.terminal_rounded,
                              color: const Color(0xFFEF4444),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(delay: 450.ms, duration: 400.ms),
                        SizedBox(height: 48.h),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// ── Gradient Summary Card (top card) ────────────────────────────────────────

class _GradientSummaryCard extends StatelessWidget {
  final int totalEntries;
  final double totalHours;
  final double expectedAmount;
  final double receivedAmount;
  final double pendingAmount;

  const _GradientSummaryCard({
    required this.totalEntries,
    required this.totalHours,
    required this.expectedAmount,
    required this.receivedAmount,
    required this.pendingAmount,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary,
            Color.lerp(primary, const Color(0xFF7C3AED), 0.6)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.work_outline_rounded,
                    color: Colors.white, size: 22.r),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Work Log Overview',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13.sp,
                    ),
                  ),
                  Text(
                    '$totalEntries Total Entries',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _WhiteStatItem(
                  label: 'Total Hours',
                  value: '${totalHours.toStringAsFixed(1)}h',
                  icon: Icons.timer_rounded,
                ),
              ),
              Container(
                  width: 1,
                  height: 36.h,
                  color: Colors.white.withValues(alpha: 0.3)),
              Expanded(
                child: _WhiteStatItem(
                  label: 'Expected',
                  value: '₹${expectedAmount.toStringAsFixed(0)}',
                  icon: Icons.currency_rupee_rounded,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _WhiteStatItem(
                  label: 'Received',
                  value: '₹${receivedAmount.toStringAsFixed(0)}',
                  icon: Icons.payments_rounded,
                ),
              ),
              Container(
                  width: 1,
                  height: 36.h,
                  color: Colors.white.withValues(alpha: 0.3)),
              Expanded(
                child: _WhiteStatItem(
                  label: 'Pending',
                  value: '₹${pendingAmount.toStringAsFixed(0)}',
                  icon: Icons.pending_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhiteStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _WhiteStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 16.r),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11.sp,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Status Count Card ────────────────────────────────────────────────────────

class _StatusCountCard extends StatelessWidget {
  final int status;
  final int count;

  const _StatusCountCard({required this.status, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = WorkLogStatusBadge.color(status);
    final label = WorkLogStatusBadge.label(status);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              _statusIcon(status),
              size: 16.r,
              color: color,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(int status) {
    switch (status) {
      case 1:
        return Icons.edit_outlined;
      case 2:
        return Icons.send_rounded;
      case 3:
        return Icons.check_circle_rounded;
      case 4:
        return Icons.cancel_rounded;
      case 5:
        return Icons.payments_rounded;
      case 6:
        return Icons.block_rounded;
      default:
        return Icons.help_outline;
    }
  }
}

// ── Work Type Row ────────────────────────────────────────────────────────────

class _WorkTypeRow extends StatelessWidget {
  final List<
      ({String label, int count, IconData icon, Color color})> entries;

  const _WorkTypeRow({required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: entries.map((e) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
                right: e == entries.last ? 0 : 10.w),
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: e.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(e.icon, size: 18.r, color: e.color),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.count.toString(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: e.color,
                      ),
                    ),
                    Text(
                      e.label,
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
        );
      }).toList(),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 48.r, color: theme.colorScheme.error.withValues(alpha: 0.4)),
          SizedBox(height: 16.h),
          const Text('Failed to load dashboard'),
          SizedBox(height: 12.h),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
