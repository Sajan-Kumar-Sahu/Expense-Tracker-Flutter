import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../contacts/presentation/providers/contacts_provider.dart';
import '../../domain/entities/settlement_entity.dart';
import '../providers/settlements_provider.dart';

class AddSettlementPage extends ConsumerStatefulWidget {
  final SettlementEntity? settlement;

  const AddSettlementPage({super.key, this.settlement});

  @override
  ConsumerState<AddSettlementPage> createState() => _AddSettlementPageState();
}

class _AddSettlementPageState extends ConsumerState<AddSettlementPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reasonController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  int _settlementType = 1;
  String? _selectedContactId;
  DateTime? _dueDate;

  bool get _isEditing => widget.settlement != null;

  @override
  void initState() {
    super.initState();
    final s = widget.settlement;
    _reasonController = TextEditingController(text: s?.reason ?? '');
    _amountController = TextEditingController(
      text: s != null ? s.originalAmount.toStringAsFixed(0) : '',
    );
    _notesController = TextEditingController(text: s?.notes ?? '');
    _settlementType = s?.settlementType ?? 1;
    _selectedContactId = s?.contactId;
    _dueDate = s?.dueDate;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedContactId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a contact'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final data = {
      'contactId': _selectedContactId,
      'settlementType': _settlementType,
      'reason': _reasonController.text.trim(),
      'originalAmount': double.tryParse(_amountController.text.trim()) ?? 0,
      'dueDate': _dueDate?.toUtc().toIso8601String(),
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    };

    final provider = ref.read(settlementsProvider);
    bool success;

    if (_isEditing) {
      success =
          await provider.updateSettlement(widget.settlement!.id, data);
    } else {
      success = await provider.createSettlement(data);
    }

    if (mounted) {
      if (success) {
        context.pop();
      } else {
        final error = ref.read(settlementsProvider).lastError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error ??
                  (_isEditing
                      ? 'Failed to update settlement'
                      : 'Failed to create settlement'),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settleProvider = ref.watch(settlementsProvider);
    final contacts = ref.watch(contactsProvider).contacts;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.r),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Settlement' : 'New Settlement',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Type', theme),
              SizedBox(height: 12.h),

              Row(
                children: [
                  _TypeChip(
                    label: 'Receivable',
                    subtitle: 'They owe you',
                    icon: Icons.arrow_downward_rounded,
                    color: const Color(0xFF10B981),
                    isSelected: _settlementType == 1,
                    onTap: () => setState(() => _settlementType = 1),
                    isDark: isDark,
                  ),
                  SizedBox(width: 12.w),
                  _TypeChip(
                    label: 'Payable',
                    subtitle: 'You owe them',
                    icon: Icons.arrow_upward_rounded,
                    color: const Color(0xFFEF4444),
                    isSelected: _settlementType == 2,
                    onTap: () => setState(() => _settlementType = 2),
                    isDark: isDark,
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              SizedBox(height: 20.h),

              _sectionLabel('Contact', theme),
              SizedBox(height: 12.h),

              DropdownButtonFormField<String>(
                value: _selectedContactId,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                        color: theme.colorScheme.primary, width: 1.5),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  hintText: 'Select contact',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                    fontSize: 14.sp,
                  ),
                ),
                hint: Text(
                  'Select contact',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                    fontSize: 14.sp,
                  ),
                ),
                items: contacts
                    .where((c) => c.isActive)
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedContactId = v),
                validator: (v) =>
                    v == null ? 'Please select a contact' : null,
              ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
              SizedBox(height: 14.h),

              _sectionLabel('Details', theme),
              SizedBox(height: 12.h),

              _buildTextField(
                controller: _reasonController,
                label: 'Reason',
                hint: 'e.g. Lunch, Trip expenses...',
                icon: Icons.description_outlined,
                isDark: isDark,
                theme: theme,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Reason is required' : null,
              ),
              SizedBox(height: 14.h),

              _buildTextField(
                controller: _amountController,
                label: 'Amount (₹)',
                hint: '0',
                icon: Icons.currency_rupee_rounded,
                isDark: isDark,
                theme: theme,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Amount is required';
                  final d = double.tryParse(v.trim());
                  if (d == null || d <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              SizedBox(height: 14.h),

              Text(
                'Due Date (optional)',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 6.h),
              GestureDetector(
                onTap: _pickDueDate,
                child: Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18.r,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        _dueDate != null
                            ? DateFormat('dd MMM yyyy').format(_dueDate!)
                            : 'No due date',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: _dueDate != null
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.35),
                        ),
                      ),
                      const Spacer(),
                      if (_dueDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _dueDate = null),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16.r,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              _buildTextField(
                controller: _notesController,
                label: 'Notes (optional)',
                hint: 'Any additional notes...',
                icon: Icons.notes_rounded,
                isDark: isDark,
                theme: theme,
                maxLines: 3,
              ),
              SizedBox(height: 32.h),

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: settleProvider.isActionLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _settlementType == 1
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: settleProvider.isActionLoading
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEditing
                              ? 'Update Settlement'
                              : (_settlementType == 1
                                  ? 'Add Receivable'
                                  : 'Add Payable'),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, ThemeData theme) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required ThemeData theme,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: maxLines == 1
                ? Icon(icon,
                    size: 20.r,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.4))
                : null,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: maxLines > 1 ? 14.h : 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:
                  BorderSide(color: theme.colorScheme.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:
                  BorderSide(color: theme.colorScheme.error, width: 1.5),
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _TypeChip({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.12)
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? color : (isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16.r),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? color
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
