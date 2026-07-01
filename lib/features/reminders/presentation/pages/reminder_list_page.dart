import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/app_router.dart';
import '../providers/notification_provider.dart';
import '../providers/reminder_provider.dart';
import '../widgets/reminder_card.dart';

class ReminderListPage extends ConsumerStatefulWidget {
  const ReminderListPage({super.key});

  @override
  ConsumerState<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends ConsumerState<ReminderListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(reminderProvider).loadReminders();
      ref.read(notificationProvider).loadNotifications();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(reminderProvider).loadReminders();
    await ref.read(reminderProvider).loadDashboard();
    await ref.read(notificationProvider).loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(reminderProvider);
    final notifProvider = ref.watch(notificationProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminders',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 26.sp,
                        ),
                      ),
                      Text(
                        'Stay on top of your tasks',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0, duration: 400.ms),
                  Row(
                    children: [
                      if (notifProvider.unreadCount > 0)
                        GestureDetector(
                          onTap: () => context.push(AppRouter.notificationList),
                          child: Stack(
                            children: [
                              Container(
                                width: 36.r,
                                height: 36.r,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Icon(Icons.notifications_rounded,
                                    size: 18.r,
                                    color: theme.colorScheme.primary),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 14.r,
                                  height: 14.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: theme.scaffoldBackgroundColor,
                                        width: 1.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      notifProvider.unreadCount > 9
                                          ? '9+'
                                          : '${notifProvider.unreadCount}',
                                      style: TextStyle(
                                          fontSize: 7.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 400.ms),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () => context.push(AppRouter.reminderDashboard),
                        child: Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Icon(Icons.dashboard_rounded,
                              size: 18.r,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6)),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // ── Filter chips ─────────────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: ReminderFilter.values.map((filter) {
                  final isActive = provider.activeFilter == filter;
                  return GestureDetector(
                    onTap: () => ref.read(reminderProvider).applyFilter(filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: isActive
                            ? theme.colorScheme.primary
                            : (isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isActive
                              ? theme.colorScheme.primary
                              : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Text(
                        _filterLabel(filter),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 400.ms),
            SizedBox(height: 12.h),

            // ── List ────────────────────────────────────────────────────────
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                      ? _ErrorState(
                          message: provider.error!,
                          onRetry: _onRefresh,
                        )
                      : RefreshIndicator(
                          onRefresh: _onRefresh,
                          color: theme.colorScheme.primary,
                          child: provider.reminders.isEmpty
                              ? _EmptyState(
                                  filter: provider.activeFilter,
                                  onAdd: () async {
                                    await context.push(AppRouter.addReminder);
                                    if (mounted) {
                                      ref.read(reminderProvider).loadReminders();
                                    }
                                  },
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                      20.w, 0, 20.w, 110.h),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  itemCount: provider.reminders.length,
                                  itemBuilder: (context, index) {
                                    final reminder =
                                        provider.reminders[index];
                                    return ReminderCard(
                                      reminder: reminder,
                                      index: index,
                                      onTap: () async {
                                        await context.push(
                                          AppRouter.reminderDetails,
                                          extra: reminder.id,
                                        );
                                        if (mounted) {
                                          ref
                                              .read(reminderProvider)
                                              .loadReminders();
                                        }
                                      },
                                    );
                                  },
                                ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 80.h),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await context.push(AppRouter.addReminder);
            if (mounted) ref.read(reminderProvider).loadReminders();
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Reminder'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5, end: 0),
    );
  }

  String _filterLabel(ReminderFilter filter) {
    switch (filter) {
      case ReminderFilter.all:
        return 'All';
      case ReminderFilter.pending:
        return 'Pending';
      case ReminderFilter.today:
        return 'Today';
      case ReminderFilter.upcoming:
        return 'Upcoming';
      case ReminderFilter.overdue:
        return 'Overdue';
    }
  }
}

class _EmptyState extends StatelessWidget {
  final ReminderFilter filter;
  final VoidCallback onAdd;

  const _EmptyState({required this.filter, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFiltered = filter != ReminderFilter.all;
    return ListView(
      children: [
        SizedBox(height: 80.h),
        Center(
          child: Column(
            children: [
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFiltered
                      ? Icons.search_off_rounded
                      : Icons.alarm_off_rounded,
                  size: 36.r,
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                isFiltered ? 'No reminders found' : 'No reminders yet',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8.h),
              Text(
                isFiltered
                    ? 'Try a different filter'
                    : 'Add your first reminder',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
              if (!isFiltered) ...[
                SizedBox(height: 24.h),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Reminder'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 48.r,
                color: theme.colorScheme.error.withValues(alpha: 0.4)),
            SizedBox(height: 16.h),
            Text('Something went wrong',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
