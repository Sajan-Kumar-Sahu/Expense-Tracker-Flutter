import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/reminder_entity.dart';
import '../providers/reminder_provider.dart';

class AddEditReminderPage extends ConsumerStatefulWidget {
  final ReminderEntity? reminder;

  const AddEditReminderPage({super.key, this.reminder});

  @override
  ConsumerState<AddEditReminderPage> createState() =>
      _AddEditReminderPageState();
}

class _AddEditReminderPageState extends ConsumerState<AddEditReminderPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _messageController;
  late final TextEditingController _notesController;

  int _reminderType = 11;
  int _referenceModule = 9;
  int _priority = 2;
  int _repeatType = 1;
  int? _repeatInterval;
  bool _isPushEnabled = true;
  bool _isInAppEnabled = true;
  DateTime _scheduledDate = DateTime.now().add(
    const Duration(minutes: 5),
  );
  DateTime? _expiresAt;
  bool _isLoading = false;

  bool get _isEditing => widget.reminder != null;

  final _reminderTypes = [
    (value: 1, label: 'Work Log Apply'),
    (value: 2, label: 'Settlement Receivable'),
    (value: 3, label: 'Settlement Payable'),
    (value: 4, label: 'Transaction'),
    (value: 5, label: 'Salary'),
    (value: 6, label: 'Bill'),
    (value: 7, label: 'Investment'),
    (value: 8, label: 'Subscription'),
    (value: 9, label: 'Insurance'),
    (value: 10, label: 'Goal'),
    (value: 11, label: 'Custom'),
    (value: 12, label: 'Other'),
  ];

  final _priorities = [
    (value: 1, label: 'Low'),
    (value: 2, label: 'Medium'),
    (value: 3, label: 'High'),
    (value: 4, label: 'Critical'),
  ];

  final _repeatTypes = [
    (value: 1, label: 'None'),
    (value: 2, label: 'Daily'),
    (value: 3, label: 'Weekly'),
    (value: 4, label: 'Monthly'),
    (value: 5, label: 'Yearly'),
    (value: 6, label: 'Custom'),
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _titleController = TextEditingController(text: r?.title ?? '');
    _messageController = TextEditingController(text: r?.message ?? '');
    _notesController = TextEditingController(text: r?.notes ?? '');

    if (r != null) {
      _reminderType = r.reminderType;
      _referenceModule = r.referenceModule;
      _priority = r.priority;
      _repeatType = r.repeatType;
      _repeatInterval = r.repeatInterval;
      _isPushEnabled = r.isPushNotificationEnabled;
      _isInAppEnabled = r.isInAppNotificationEnabled;
      try {
        _scheduledDate = DateTime.parse(
          r.scheduledDate,
        ).toLocal();
      } catch (_) {}
      if (r.expiresAt != null) {
        try {
          _expiresAt = DateTime.parse(r.expiresAt!);
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isExpiry}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isExpiry ? (_expiresAt ?? _scheduledDate) : _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      if (isExpiry) {
        _expiresAt = picked;
      } else {
        _scheduledDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _scheduledDate.hour,
          _scheduledDate.minute,
        );
      }
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledDate),
    );

    if (picked == null) return;

    setState(() {
      _scheduledDate = DateTime(
        _scheduledDate.year,
        _scheduledDate.month,
        _scheduledDate.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = <String, dynamic>{
      'reminderType': _reminderType,
      'referenceModule': _referenceModule,
      'referenceId': _generateReferenceId(),
      'title': _titleController.text.trim(),
      'message': _messageController.text.trim(),
      'scheduledDate': _scheduledDate.toUtc().toIso8601String(),
      'priority': _priority,
      'repeatType': _repeatType,
      if (_repeatInterval != null) 'repeatInterval': _repeatInterval,
      'isPushNotificationEnabled': _isPushEnabled,
      'isInAppNotificationEnabled': _isInAppEnabled,
      if (_expiresAt != null) 'expiresAt': _expiresAt!.toUtc().toIso8601String(),
      if (_notesController.text.trim().isNotEmpty)
        'notes': _notesController.text.trim(),
    };
    if (_scheduledDate.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reminder time cannot be in the past',
          ),
        ),
      );

      setState(() => _isLoading = false);
      return;
    }

    final provider = ref.read(reminderProvider);
    bool success;
    if (_isEditing) {
      success = await provider.updateReminder(widget.reminder!.id, data);
    } else {
      success = await provider.createReminder(data);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEditing ? 'Failed to update reminder' : 'Failed to add reminder'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String _generateReferenceId() {
    // Generate a deterministic-looking UUID v4 using current timestamp
    final now = DateTime.now().millisecondsSinceEpoch;
    final hex = now.toRadixString(16).padLeft(12, '0');
    return '00000000-0000-4000-8000-$hex';
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
          _isEditing ? 'Edit Reminder' : 'Add Reminder',
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              _SectionLabel(label: 'Title'),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Enter reminder title', isDark),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              SizedBox(height: 16.h),

              // Message
              _SectionLabel(label: 'Message'),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration:
                    _inputDecoration('Enter reminder message', isDark),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Message is required' : null,
              ),
              SizedBox(height: 16.h),

              // Reminder Type
              _SectionLabel(label: 'Reminder Type'),
              _DropdownField<int>(
                value: _reminderType,
                isDark: isDark,
                items: _reminderTypes
                    .map((t) => DropdownMenuItem(
                        value: t.value, child: Text(t.label)))
                    .toList(),
                onChanged: (v) => setState(() => _reminderType = v!),
              ),
              SizedBox(height: 16.h),

              // Priority
              _SectionLabel(label: 'Priority'),
              _DropdownField<int>(
                value: _priority,
                isDark: isDark,
                items: _priorities
                    .map((p) => DropdownMenuItem(
                        value: p.value, child: Text(p.label)))
                    .toList(),
                onChanged: (v) => setState(() => _priority = v!),
              ),
              SizedBox(height: 16.h),

              // Scheduled Date
              _SectionLabel(label: 'Scheduled Date'),
              GestureDetector(
                onTap: () => _pickDate(isExpiry: false),
                child: _DateField(
                  date: _scheduledDate,
                  hint: 'Pick scheduled date',
                  isDark: isDark,
                  theme: theme,
                ),
              ),
              SizedBox(height: 16.h),
              _SectionLabel(label: 'Reminder Time'),

              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18.r,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        DateFormat('hh:mm a').format(_scheduledDate),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Repeat Type
              _SectionLabel(label: 'Repeat'),
              _DropdownField<int>(
                value: _repeatType,
                isDark: isDark,
                items: _repeatTypes
                    .map((r) => DropdownMenuItem(
                        value: r.value, child: Text(r.label)))
                    .toList(),
                onChanged: (v) => setState(() => _repeatType = v!),
              ),
              SizedBox(height: 16.h),

              // Expires At
              _SectionLabel(label: 'Expires At (optional)'),
              GestureDetector(
                onTap: () => _pickDate(isExpiry: true),
                child: _DateField(
                  date: _expiresAt,
                  hint: 'Pick expiry date (optional)',
                  isDark: isDark,
                  theme: theme,
                  isClearable: _expiresAt != null,
                  onClear: () => setState(() => _expiresAt = null),
                ),
              ),
              SizedBox(height: 16.h),

              // Notes
              _SectionLabel(label: 'Notes (optional)'),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration:
                    _inputDecoration('Add any additional notes...', isDark),
              ),
              SizedBox(height: 16.h),

              // Notification toggles
              _SectionLabel(label: 'Notifications'),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      title: Text('Push Notifications',
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.w500)),
                      value: _isPushEnabled,
                      onChanged: (v) => setState(() => _isPushEnabled = v),
                      activeThumbColor: theme.colorScheme.primary,
                      activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    Divider(
                        height: 1,
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0)),
                    SwitchListTile.adaptive(
                      title: Text('In-App Notifications',
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.w500)),
                      value: _isInAppEnabled,
                      onChanged: (v) => setState(() => _isInAppEnabled = v),
                      activeThumbColor: theme.colorScheme.primary,
                      activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Reminder' : 'Add Reminder',
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error, width: 1.5),
      ),
      filled: true,
      fillColor:
          isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isDark;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor:
              isDark ? const Color(0xFF1E293B) : Colors.white,
          style: TextStyle(
            fontSize: 14.sp,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? date;
  final String hint;
  final bool isDark;
  final ThemeData theme;
  final bool isClearable;
  final VoidCallback? onClear;

  const _DateField({
    required this.date,
    required this.hint,
    required this.isDark,
    required this.theme,
    this.isClearable = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded,
              size: 18.r,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              date != null
                  ? DateFormat('MMM d, yyyy').format(date!)
                  : hint,
              style: TextStyle(
                fontSize: 14.sp,
                color: date != null
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          if (isClearable)
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close_rounded,
                  size: 16.r,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            ),
        ],
      ),
    );
  }
}
