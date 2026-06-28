import 'package:expense_tracker/features/worklog/domain/entities/work_log_entity.dart';
import 'package:expense_tracker/features/worklog/presentation/pages/add_edit_work_log_page.dart';
import 'package:expense_tracker/features/worklog/presentation/providers/work_log_provider.dart';
import 'package:expense_tracker/features/worklog/presentation/widgets/work_log_status_badge.dart';
import 'package:expense_tracker/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class WorkLogDetailsPage extends ConsumerStatefulWidget {
  final String workLogId;

  const WorkLogDetailsPage({super.key, required this.workLogId});

  @override
  ConsumerState<WorkLogDetailsPage> createState() =>
      _WorkLogDetailsPageState();
}

class _WorkLogDetailsPageState extends ConsumerState<WorkLogDetailsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(workLogProvider).loadWorkLogById(widget.workLogId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(workLogProvider);
    final workLog = provider.selectedWorkLog;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : workLog == null
              ? _EmptyState()
              : CustomScrollView(
                  slivers: [
                    // ── Header / Hero ─────────────────────────────────────
                    SliverAppBar(
                      expandedHeight: 200.h,
                      pinned: true,
                      backgroundColor: colorScheme.surface,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      leading: _CircleIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => context.pop(),
                      ),
                      actions: _buildActions(context, workLog.status),
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        background: _HeroSection(workLog: workLog),
                      ),
                    ),

                    // ── Body ──────────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 48.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 2-col stats
                            Row(
                              children: [
                                Expanded(
                                  child: _StatChip(
                                    label: 'Worked Hours',
                                    value:
                                        '${workLog.workedHours.toStringAsFixed(1)} hrs',
                                    iconData: Icons.timer_rounded,
                                    iconBg: const Color(0xFFEEEDFE),
                                    iconColor: const Color(0xFF534AB7),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: _StatChip(
                                    label: 'Expected',
                                    value: workLog.expectedAmount != null
                                        ? '₹${workLog.expectedAmount!.toStringAsFixed(0)}'
                                        : 'Not set',
                                    iconData: Icons.currency_rupee_rounded,
                                    iconBg: const Color(0xFFFAEEDA),
                                    iconColor: const Color(0xFF854F0B),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),

                            // Work log info
                            _SectionLabel(label: 'Work Log Info'),
                            SizedBox(height: 10.h),
                            _DetailCard(children: [
                              _DetailRow(
                                iconData: Icons.folder_rounded,
                                iconBg: const Color(0xFFE6F1FB),
                                iconColor: const Color(0xFF185FA5),
                                label: 'Project',
                                value: workLog.projectName,
                              ),
                              _CardDivider(),
                              _DetailRow(
                                iconData: Icons.work_outline_rounded,
                                iconBg: const Color(0xFFE1F5EE),
                                iconColor: const Color(0xFF0F6E56),
                                label: 'Work Type',
                                value: _workTypeLabel(workLog.workType),
                              ),
                              _CardDivider(),
                              _DetailRow(
                                iconData: Icons.calendar_today_outlined,
                                iconBg: const Color(0xFFEEEDFE),
                                iconColor: const Color(0xFF534AB7),
                                label: 'Work Date',
                                value: _formatDate(workLog.workDate),
                              ),
                              _CardDivider(),
                              _DetailRow(
                                iconData: Icons.access_time_rounded,
                                iconBg: const Color(0xFFF1EFE8),
                                iconColor: const Color(0xFF5F5E5A),
                                label: 'Time',
                                value:
                                    '${_formatTimeStr(workLog.startTime)} – ${_formatTimeStr(workLog.endTime)}',
                              ),
                            ]),
                            SizedBox(height: 24.h),

                            // Task details
                            _SectionLabel(label: 'Task Details'),
                            SizedBox(height: 10.h),
                            _DetailCard(children: [
                              _DetailRow(
                                iconData: Icons.task_alt_rounded,
                                iconBg: const Color(0xFFEEEDFE),
                                iconColor: const Color(0xFF534AB7),
                                label: 'Task Title',
                                value: workLog.taskTitle,
                              ),
                              if (workLog.description != null &&
                                  workLog.description!.isNotEmpty) ...[
                                _CardDivider(),
                                _DetailRow(
                                  iconData: Icons.description_outlined,
                                  iconBg: const Color(0xFFF1EFE8),
                                  iconColor: const Color(0xFF5F5E5A),
                                  label: 'Description',
                                  value: workLog.description!,
                                ),
                              ],
                              if (workLog.referenceNumber != null &&
                                  workLog.referenceNumber!.isNotEmpty) ...[
                                _CardDivider(),
                                _DetailRow(
                                  iconData: Icons.tag_rounded,
                                  iconBg: const Color(0xFFE1F5EE),
                                  iconColor: const Color(0xFF0F6E56),
                                  label: 'Reference No.',
                                  value: workLog.referenceNumber!,
                                ),
                              ],
                            ]),
                            SizedBox(height: 24.h),

                            // Financial
                            _SectionLabel(label: 'Financial'),
                            SizedBox(height: 10.h),
                            _DetailCard(children: [
                              _DetailRow(
                                iconData: Icons.currency_rupee_rounded,
                                iconBg: const Color(0xFFFAEEDA),
                                iconColor: const Color(0xFF854F0B),
                                label: 'Expected Amount',
                                value: workLog.expectedAmount != null
                                    ? '₹${workLog.expectedAmount!.toStringAsFixed(2)}'
                                    : 'Not specified',
                              ),
                              _CardDivider(),
                              _DetailRow(
                                iconData: Icons.payments_rounded,
                                iconBg: const Color(0xFFE1F5EE),
                                iconColor: const Color(0xFF0F6E56),
                                label: 'Actual Amount',
                                value: workLog.actualAmount != null
                                    ? '₹${workLog.actualAmount!.toStringAsFixed(2)}'
                                    : '—',
                              ),
                              if (workLog.paymentMonth != null) ...[
                                _CardDivider(),
                                _DetailRow(
                                  iconData: Icons.calendar_month_rounded,
                                  iconBg: const Color(0xFFE6F1FB),
                                  iconColor: const Color(0xFF185FA5),
                                  label: 'Payment Month',
                                  value: workLog.paymentMonth!,
                                ),
                              ],
                            ]),
                            SizedBox(height: 24.h),

                            // Timeline
                            _SectionLabel(label: 'Timeline'),
                            SizedBox(height: 10.h),
                            _DetailCard(children: [
                              _DetailRow(
                                iconData: Icons.send_rounded,
                                iconBg: const Color(0xFFE6F1FB),
                                iconColor: const Color(0xFF185FA5),
                                label: 'Applied Date',
                                value: workLog.appliedDate != null
                                    ? _formatDate(workLog.appliedDate!)
                                    : '—',
                              ),
                              _CardDivider(),
                              _DetailRow(
                                iconData: Icons.check_circle_outline,
                                iconBg: const Color(0xFFE1F5EE),
                                iconColor: const Color(0xFF0F6E56),
                                label: 'Approved Date',
                                value: workLog.approvedDate != null
                                    ? _formatDate(workLog.approvedDate!)
                                    : '—',
                              ),
                              _CardDivider(),
                              _DetailRow(
                                iconData: Icons.payments_outlined,
                                iconBg: const Color(0xFFEEEDFE),
                                iconColor: const Color(0xFF534AB7),
                                label: 'Paid Date',
                                value: workLog.paidDate != null
                                    ? _formatDate(workLog.paidDate!)
                                    : '—',
                              ),
                            ]),

                            if (workLog.notes != null &&
                                workLog.notes!.isNotEmpty) ...[
                              SizedBox(height: 24.h),
                              _SectionLabel(label: 'Notes'),
                              SizedBox(height: 10.h),
                              _NotesCard(notes: workLog.notes!),
                            ],

                            // Status action buttons
                            SizedBox(height: 32.h),
                            _StatusActionsSection(
                              workLogId: workLog.id,
                              status: workLog.status,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  List<Widget> _buildActions(BuildContext context, int status) {
    final provider = ref.read(workLogProvider);
    final workLog = provider.selectedWorkLog;
    if (workLog == null) return [];

    return [
      _CircleIconButton(
        icon: Icons.edit_outlined,
        onTap: () => context.push(AppRouter.editWorkLog, extra: workLog),
      ),
      SizedBox(width: 6.w),
      _CircleIconButton(
        icon: Icons.delete_outline_rounded,
        onTap: () => _confirmDelete(context, workLog.id),
        isDestructive: true,
      ),
      SizedBox(width: 12.w),
    ];
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text('Delete Work Log'),
        content: const Text(
          'Are you sure you want to delete this work log? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success =
        await ref.read(workLogProvider).deleteWorkLog(id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Work log deleted' : 'Failed to delete work log',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        backgroundColor: success
            ? null
            : Theme.of(context).colorScheme.error,
      ),
    );

    if (success) context.go(AppRouter.home);
  }

  String _workTypeLabel(int wt) {
    const labels = {
      1: 'Weekend',
      2: 'Public Holiday',
      3: 'On-Call Support',
      4: 'Late Night Deployment',
      5: 'Production Support',
      6: 'Client Support',
      7: 'Emergency Work',
      8: 'Other',
    };
    return labels[wt] ?? 'Unknown';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTimeStr(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final tod = TimeOfDay(hour: h, minute: m);
      final suffix = h < 12 ? 'AM' : 'PM';
      final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '${hour12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $suffix';
    } catch (_) {
      return timeStr;
    }
  }
}

// ── Status Actions Section ─────────────────────────────────────────────────

class _StatusActionsSection extends ConsumerWidget {
  final String workLogId;
  final int status;

  const _StatusActionsSection({
    required this.workLogId,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final List<Widget> actions = [];

    // Status 1 = Draft → can Apply
    if (status == 1) {
      actions.add(_ActionButton(
        label: 'Apply',
        icon: Icons.send_rounded,
        color: const Color(0xFF3B82F6),
        onTap: () => _doStatusAction(context, ref, () async {
          return await ref.read(workLogProvider).apply(workLogId);
        }, 'Applied successfully'),
      ));
    }

    // Status 2 = Applied → can Approve or Reject
    if (status == 2) {
      actions.add(_ActionButton(
        label: 'Approve',
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF10B981),
        onTap: () => _doStatusAction(context, ref, () async {
          return await ref.read(workLogProvider).approve(workLogId);
        }, 'Approved successfully'),
      ));
      actions.add(SizedBox(width: 12.w));
      actions.add(_ActionButton(
        label: 'Reject',
        icon: Icons.cancel_rounded,
        color: theme.colorScheme.error,
        onTap: () => _doStatusAction(context, ref, () async {
          return await ref.read(workLogProvider).reject(workLogId);
        }, 'Rejected'),
      ));
    }

    // Status 3 = Approved → can Mark Paid
    if (status == 3) {
      actions.add(_ActionButton(
        label: 'Mark Paid',
        icon: Icons.payments_rounded,
        color: const Color(0xFF8B5CF6),
        onTap: () => _showMarkPaidDialog(context, ref),
      ));
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIONS',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        SizedBox(height: 12.h),
        Row(children: actions),
      ],
    );
  }

  Future<void> _doStatusAction(
    BuildContext context,
    WidgetRef ref,
    Future<bool> Function() action,
    String successMsg,
  ) async {
    final success = await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? successMsg : 'Action failed'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: success
            ? null
            : Theme.of(context).colorScheme.error,
      ),
    );
    if (success) {
      // Reload details
      ref.read(workLogProvider).loadWorkLogById(workLogId);
    }
  }

  void _showMarkPaidDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final monthController = TextEditingController(
        text: DateFormat('MMMM yyyy').format(DateTime.now()));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Mark as Paid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Actual Amount (₹)',
                prefixIcon: Icon(Icons.currency_rupee_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: monthController,
              decoration: const InputDecoration(
                labelText: 'Payment Month',
                prefixIcon: Icon(Icons.calendar_month_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim());
              final month = monthController.text.trim();
              if (amount == null || month.isEmpty) return;
              Navigator.pop(ctx);
              final success = await ref.read(workLogProvider).markPaid(
                    workLogId,
                    amount,
                    month,
                  );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      success ? 'Marked as Paid' : 'Failed to mark paid'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              if (success) {
                ref.read(workLogProvider).loadWorkLogById(workLogId);
              }
            },
            child: const Text('Mark Paid'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.r, color: color),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero section ───────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final WorkLogEntity workLog;
  const _HeroSection({required this.workLog});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = WorkLogStatusBadge.color(workLog.status);

    return Container(
      width: double.infinity,
      color: colorScheme.surface,
      padding: EdgeInsets.fromLTRB(20.w, 90.h, 20.w, 20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkLogStatusBadge(status: workLog.status),
          SizedBox(height: 8.h),
          Text(
            workLog.taskTitle.isNotEmpty ? workLog.taskTitle : 'Work Log',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6.h),
          Text(
            '${workLog.projectName} · ${workLog.workedHours.toStringAsFixed(1)} hrs',
            style: TextStyle(
              fontSize: 13.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable detail widgets ────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData iconData;
  final Color iconBg;
  final Color iconColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.iconData,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(iconData, size: 18.sp, color: iconColor),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData iconData;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.iconData,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(iconData, size: 17.sp, color: iconColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0,
      thickness: 0.5,
      indent: 64.w,
      color: Theme.of(context)
          .colorScheme
          .outlineVariant
          .withValues(alpha: 0.5),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;
  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: const Color(0xFFF1EFE8),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.notes_rounded,
              size: 17.sp,
              color: const Color(0xFF5F5E5A),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              notes,
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.75),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: isDestructive
              ? colorScheme.error.withValues(alpha: 0.08)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: isDestructive
              ? colorScheme.error
              : colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline_rounded,
              size: 32.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Work log not found',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
