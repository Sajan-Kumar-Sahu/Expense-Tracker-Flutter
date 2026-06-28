import 'package:expense_tracker/features/worklog/presentation/providers/work_log_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom sheet for worklog filtering — mirrors existing UI pattern.
class WorkLogFilterSheet extends StatefulWidget {
  final WorkLogFilter currentFilter;
  final List<({String id, String name})> projects;
  final void Function(WorkLogFilter) onApply;

  const WorkLogFilterSheet({
    super.key,
    required this.currentFilter,
    required this.projects,
    required this.onApply,
  });

  @override
  State<WorkLogFilterSheet> createState() => _WorkLogFilterSheetState();
}

class _WorkLogFilterSheetState extends State<WorkLogFilterSheet> {
  late int? _selectedStatus;
  late int? _selectedWorkType;
  late String? _selectedProjectId;
  late int? _selectedMonth;
  late int? _selectedYear;

  final _statuses = [
    (value: 1, label: 'Draft'),
    (value: 2, label: 'Applied'),
    (value: 3, label: 'Approved'),
    (value: 4, label: 'Rejected'),
    (value: 5, label: 'Paid'),
    (value: 6, label: 'Cancelled'),
  ];

  final _workTypes = [
    (value: 1, label: 'Weekend'),
    (value: 2, label: 'Public Holiday'),
    (value: 3, label: 'On-Call'),
    (value: 4, label: 'Late Night'),
    (value: 5, label: 'Prod Support'),
    (value: 6, label: 'Client Support'),
    (value: 7, label: 'Emergency'),
    (value: 8, label: 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentFilter.status;
    _selectedWorkType = widget.currentFilter.workType;
    _selectedProjectId = widget.currentFilter.projectId;
    _selectedMonth = widget.currentFilter.month;
    _selectedYear = widget.currentFilter.year;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Work Logs',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedStatus = null;
                        _selectedWorkType = null;
                        _selectedProjectId = null;
                        _selectedMonth = null;
                        _selectedYear = null;
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Status filter
              _FilterSection(
                label: 'Status',
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _statuses.map((s) {
                    final isSelected = _selectedStatus == s.value;
                    return _FilterChip(
                      label: s.label,
                      isSelected: isSelected,
                      onTap: () => setState(() {
                        _selectedStatus = isSelected ? null : s.value;
                      }),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16.h),

              // Work Type filter
              _FilterSection(
                label: 'Work Type',
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _workTypes.map((wt) {
                    final isSelected = _selectedWorkType == wt.value;
                    return _FilterChip(
                      label: wt.label,
                      isSelected: isSelected,
                      onTap: () => setState(() {
                        _selectedWorkType = isSelected ? null : wt.value;
                      }),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16.h),

              // Project filter
              if (widget.projects.isNotEmpty) ...[
                _FilterSection(
                  label: 'Project',
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: widget.projects.map((p) {
                      final isSelected = _selectedProjectId == p.id;
                      return _FilterChip(
                        label: p.name,
                        isSelected: isSelected,
                        onTap: () => setState(() {
                          _selectedProjectId = isSelected ? null : p.id;
                        }),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // Month filter (Jan–Dec)
              _FilterSection(
                label: 'Month',
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: List.generate(12, (i) {
                    final m = i + 1;
                    final label = [
                      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                    ][i];
                    final isSelected = _selectedMonth == m;
                    return _FilterChip(
                      label: label,
                      isSelected: isSelected,
                      onTap: () =>
                          setState(() => _selectedMonth = isSelected ? null : m),
                    );
                  }),
                ),
              ),
              SizedBox(height: 24.h),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(WorkLogFilter(
                      status: _selectedStatus,
                      workType: _selectedWorkType,
                      projectId: _selectedProjectId,
                      month: _selectedMonth,
                      year: _selectedYear,
                    ));
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: Size.fromHeight(52.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String label;
  final Widget child;
  const _FilterSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
