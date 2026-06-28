import 'package:expense_tracker/core/utils/app_refresh.dart';
import 'package:expense_tracker/core/widgets/custom_button.dart';
import 'package:expense_tracker/core/widgets/custom_text_field.dart';
import 'package:expense_tracker/features/worklog/domain/entities/work_log_entity.dart';
import 'package:expense_tracker/features/worklog/presentation/providers/work_log_provider.dart';
import 'package:expense_tracker/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AddEditWorkLogPage extends ConsumerStatefulWidget {
  final WorkLogEntity? workLog;

  const AddEditWorkLogPage({super.key, this.workLog});

  @override
  ConsumerState<AddEditWorkLogPage> createState() => _AddEditWorkLogPageState();
}

class _AddEditWorkLogPageState extends ConsumerState<AddEditWorkLogPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _taskTitleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _expectedAmountController;
  late final TextEditingController _notesController;
  late final TextEditingController _workedHoursController;
  late final TextEditingController _referenceController;

  String? _selectedProjectId;
  int _selectedWorkType = 1;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  bool _isManualHours = false;

  bool _isLoading = false;
  bool get _isEditing => widget.workLog != null;

  final _workTypes = [
    (value: 1, label: 'Weekend'),
    (value: 2, label: 'Public Holiday'),
    (value: 3, label: 'On-Call Support'),
    (value: 4, label: 'Late Night Deployment'),
    (value: 5, label: 'Production Support'),
    (value: 6, label: 'Client Support'),
    (value: 7, label: 'Emergency Work'),
    (value: 8, label: 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    final wl = widget.workLog;

    _taskTitleController =
        TextEditingController(text: wl?.taskTitle ?? '');
    _descriptionController =
        TextEditingController(text: wl?.description ?? '');
    _expectedAmountController = TextEditingController(
        text: wl?.expectedAmount?.toString() ?? '');
    _notesController = TextEditingController(text: wl?.notes ?? '');
    _referenceController =
        TextEditingController(text: wl?.referenceNumber ?? '');

    if (wl != null) {
      _selectedProjectId = wl.projectId;
      _selectedWorkType = wl.workType;
      try {
        _selectedDate = DateTime.parse(wl.workDate);
      } catch (_) {}
      _startTime = _parseTime(wl.startTime);
      _endTime = _parseTime(wl.endTime);
      _workedHoursController =
          TextEditingController(text: wl.workedHours.toStringAsFixed(2));
      _isManualHours = true;
    } else {
      _workedHoursController = TextEditingController(
        text: _formatDecimalHours(_calculateHours(_startTime, _endTime)),
      );
    }

    Future.microtask(() {
      if (mounted) ref.read(workLogProvider).loadProjects();
    });
  }

  @override
  void dispose() {
    _taskTitleController.dispose();
    _descriptionController.dispose();
    _expectedAmountController.dispose();
    _notesController.dispose();
    _referenceController.dispose();
    _workedHoursController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(
          hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  double _calculateHours(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final diff = endMinutes - startMinutes;
    if (diff <= 0) return 0;
    return diff / 60.0;
  }

  // "9.5" not "9.50" — avoids looking like HH:MM clock time
  String _formatDecimalHours(double hours) {
    if (hours == hours.truncateToDouble()) return hours.toInt().toString();
    return hours.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '');
  }

  // "9.5 hrs" → "9h 30m"
  String _hoursToReadable(double hours) {
    final totalMinutes = (hours * 60).round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  void _updateWorkedHoursFromTimes() {
    if (!_isManualHours) {
      setState(() {
        _workedHoursController.text =
            _formatDecimalHours(_calculateHours(_startTime, _endTime));
      });
    }
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (selected != null) setState(() => _selectedDate = selected);
  }

  Future<void> _pickStartTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (selected != null) {
      setState(() {
        _startTime = selected;
        _isManualHours = false;
        _updateWorkedHoursFromTimes();
      });
    }
  }

  Future<void> _pickEndTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (selected != null) {
      setState(() {
        _endTime = selected;
        _isManualHours = false;
        _updateWorkedHoursFromTimes();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'projectId': _selectedProjectId,
      'workType': _selectedWorkType,
      'workDate': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'startTime': _formatTime(_startTime),
      'endTime': _formatTime(_endTime),
      'workedHours': double.tryParse(_workedHoursController.text.trim()),
      'taskTitle': _taskTitleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'expectedAmount':
          double.tryParse(_expectedAmountController.text.trim()),
      'referenceNumber': _referenceController.text.trim().isEmpty
          ? null
          : _referenceController.text.trim(),
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    };

    bool success;
    if (_isEditing) {
      success = await ref
          .read(workLogProvider)
          .updateWorkLog(widget.workLog!.id, data);
    } else {
      success = await ref.read(workLogProvider).createWorkLog(data);
    }

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (success) {
      await refreshAllWithWorkLog(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Work log updated successfully'
              : 'Work log created successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r)),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(workLogProvider).error ??
              'Failed to save work log'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(workLogProvider);
    final activeProjects = provider.projects.where((p) => p.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Work Log' : 'Add Work Log'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Project ───────────────────────────────────────────────────
              _SectionLabel(label: 'Project'),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                value: activeProjects.any((p) => p.id == _selectedProjectId)
                    ? _selectedProjectId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Project',
                  prefixIcon: Icon(Icons.folder_rounded),
                ),
                items: activeProjects
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        ))
                    .toList(),
                validator: (v) =>
                    v == null ? 'Please select a project' : null,
                onChanged: (v) => setState(() => _selectedProjectId = v),
              ),
              SizedBox(height: 16.h),

              // ── Work Type ─────────────────────────────────────────────────
              DropdownButtonFormField<int>(
                value: _selectedWorkType,
                decoration: const InputDecoration(
                  labelText: 'Work Type',
                  prefixIcon: Icon(Icons.work_outline_rounded),
                ),
                items: _workTypes
                    .map((wt) => DropdownMenuItem(
                          value: wt.value,
                          child: Text(wt.label),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedWorkType = v);
                },
              ),
              SizedBox(height: 16.h),

              // ── Work Date ─────────────────────────────────────────────────
              _SectionLabel(label: 'Date & Time'),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).dividerColor, width: 1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 18.r,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5)),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Work Date',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          Text(
                            DateFormat('dd MMM yyyy').format(_selectedDate),
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded,
                          size: 20.r,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // ── Start + End Time ──────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickStartTime,
                      child: _TimePickerTile(
                          label: 'Start Time', time: _startTime),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickEndTime,
                      child:
                          _TimePickerTile(label: 'End Time', time: _endTime),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // ── Worked Hours ──────────────────────────────────────────────
              TextFormField(
                controller: _workedHoursController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                ],
                decoration: InputDecoration(
                  labelText: 'Worked Hours',
                  prefixIcon: const Icon(Icons.timer_outlined),
                  hintText: 'Auto-calculated or enter manually',
                  helperText: () {
                    final h = double.tryParse(
                            _workedHoursController.text.trim()) ??
                        0;
                    return '= ${_hoursToReadable(h)}  (decimal: 1.5 = 1h 30m)';
                  }(),
                  helperStyle: TextStyle(fontSize: 11.sp),
                ),
                onChanged: (v) {
                  setState(() => _isManualHours = true);
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter hours';
                  if (double.tryParse(v.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              // ── Task Info ─────────────────────────────────────────────────
              _SectionLabel(label: 'Task Details'),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: _taskTitleController,
                labelText: 'Task Title',
                prefixIcon: const Icon(Icons.task_rounded),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter task title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 12.h),

              // ── Amount ────────────────────────────────────────────────────
              CustomTextField(
                controller: _expectedAmountController,
                labelText: 'Expected Amount (₹)',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(Icons.currency_rupee_rounded),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                ],
              ),
              SizedBox(height: 12.h),

              CustomTextField(
                controller: _referenceController,
                labelText: 'Reference Number (optional)',
                prefixIcon: const Icon(Icons.tag_rounded),
              ),
              SizedBox(height: 12.h),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.notes_rounded),
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 32.h),

              CustomButton(
                text: _isEditing ? 'Save Changes' : 'Create Work Log',
                isLoading: _isLoading,
                onPressed: _save,
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section Label ──────────────────────────────────────────────────────────

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
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }
}

// ── Time Picker Tile ───────────────────────────────────────────────────────

class _TimePickerTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;

  const _TimePickerTile({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).dividerColor, width: 1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16.r,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                time.format(context),
                style:
                    TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Extend global refresh to also reload work logs.
Future<void> refreshAllWithWorkLog(WidgetRef ref) async {
  await Future.wait([
    ref.read(workLogProvider).refresh(),
  ]);
  await refreshAll(ref);
}
