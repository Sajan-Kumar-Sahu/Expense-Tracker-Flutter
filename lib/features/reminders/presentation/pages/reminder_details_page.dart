import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../dependency_injection/injection.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../../../routes/app_router.dart';
import '../providers/reminder_provider.dart';
import '../widgets/reminder_priority_badge.dart';
import '../widgets/reminder_status_badge.dart';

class ReminderDetailsPage extends ConsumerStatefulWidget {
  final String reminderId;

  const ReminderDetailsPage({super.key, required this.reminderId});

  @override
  ConsumerState<ReminderDetailsPage> createState() =>
      _ReminderDetailsPageState();
}

class _ReminderDetailsPageState extends ConsumerState<ReminderDetailsPage> {
  ReminderEntity? _reminder;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final reminder = await locator<ReminderRepository>()
          .getReminderById(widget.reminderId);
      setState(() {
        _reminder = reminder;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteReminder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text(
            'Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await ref
        .read(reminderProvider)
        .deleteReminder(widget.reminderId);

    if (!mounted) return;
    if (success) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to delete reminder'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Reminder Details',
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface),
        ),
        actions: [
          if (_reminder != null) ...[
            IconButton(
              icon: Icon(Icons.edit_rounded,
                  size: 20.r, color: theme.colorScheme.primary),
              onPressed: () async {
                await context.push(
                  AppRouter.editReminder,
                  extra: _reminder,
                );
                if (mounted) _loadReminder();
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  size: 20.r, color: theme.colorScheme.error),
              onPressed: _deleteReminder,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off_rounded,
                          size: 48.r,
                          color: theme.colorScheme.error
                              .withValues(alpha: 0.4)),
                      SizedBox(height: 16.h),
                      OutlinedButton.icon(
                        onPressed: _loadReminder,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _reminder == null
                  ? const Center(child: Text('Reminder not found'))
                  : _buildBody(context, _reminder!, isDark, theme),
    );
  }

  Widget _buildBody(
      BuildContext context, ReminderEntity r, bool isDark, ThemeData theme) {
    DateTime? scheduledDt;
    try {
      scheduledDt = DateTime.parse(r.scheduledDate);
    } catch (_) {}
    DateTime? expiresAt;
    try {
      if (r.expiresAt != null) expiresAt = DateTime.parse(r.expiresAt!);
    } catch (_) {}

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ReminderStatusBadge(status: r.status),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  r.message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    ReminderPriorityBadge(priority: r.priority),
                    SizedBox(width: 8.w),
                    if (r.repeatType != 1)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.repeat_rounded,
                                size: 12.r,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5)),
                            SizedBox(width: 4.w),
                            Text(
                              _repeatLabel(r.repeatType),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.05, end: 0, duration: 400.ms),
          SizedBox(height: 16.h),

          // Details
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.schedule_rounded,
                  label: 'Scheduled',
                  value: scheduledDt != null
                      ? DateFormat('MMM d, y').format(scheduledDt)
                      : '-',
                  isDark: isDark,
                  theme: theme,
                  showDivider: true,
                ),
                if (expiresAt != null)
                  _DetailRow(
                    icon: Icons.timer_off_rounded,
                    label: 'Expires',
                    value: DateFormat('MMM d, y').format(expiresAt),
                    isDark: isDark,
                    theme: theme,
                    showDivider: true,
                  ),
                _DetailRow(
                  icon: Icons.notifications_rounded,
                  label: 'Push Notification',
                  value: r.isPushNotificationEnabled ? 'Enabled' : 'Disabled',
                  isDark: isDark,
                  theme: theme,
                  showDivider: true,
                ),
                _DetailRow(
                  icon: Icons.notifications_active_rounded,
                  label: 'In-App Notification',
                  value: r.isInAppNotificationEnabled ? 'Enabled' : 'Disabled',
                  isDark: isDark,
                  theme: theme,
                  showDivider: false,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 400.ms),
          SizedBox(height: 16.h),

          if (r.notes != null && r.notes!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    r.notes!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.75),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 250.ms, duration: 400.ms),
            SizedBox(height: 16.h),
          ],

          // Meta
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Created',
                  value: DateFormat('MMM d, y').format(r.createdAt),
                  isDark: isDark,
                  theme: theme,
                  showDivider: r.updatedAt != null,
                ),
                if (r.updatedAt != null)
                  _DetailRow(
                    icon: Icons.update_rounded,
                    label: 'Updated',
                    value: DateFormat('MMM d, y').format(r.updatedAt!),
                    isDark: isDark,
                    theme: theme,
                    showDivider: false,
                  ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms),
        ],
      ),
    );
  }

  String _repeatLabel(int repeat) {
    switch (repeat) {
      case 2:
        return 'Daily';
      case 3:
        return 'Weekly';
      case 4:
        return 'Monthly';
      case 5:
        return 'Yearly';
      case 6:
        return 'Custom';
      default:
        return 'None';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final ThemeData theme;
  final bool showDivider;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    required this.theme,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(icon,
                  size: 18.r,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 46.w,
            color: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
          ),
      ],
    );
  }
}
