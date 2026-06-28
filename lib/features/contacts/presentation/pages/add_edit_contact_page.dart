import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/contact_entity.dart';
import '../providers/contacts_provider.dart';

class AddEditContactPage extends ConsumerStatefulWidget {
  final ContactEntity? contact;

  const AddEditContactPage({super.key, this.contact});

  @override
  ConsumerState<AddEditContactPage> createState() => _AddEditContactPageState();
}

class _AddEditContactPageState extends ConsumerState<AddEditContactPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _notesController;

  int _contactType = 1;
  bool _isActive = true;

  bool get _isEditing => widget.contact != null;

  static const _contactTypes = [
    (value: 1, label: 'Friend'),
    (value: 2, label: 'Family'),
    (value: 3, label: 'Business'),
    (value: 4, label: 'Platform'),
    (value: 5, label: 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _nameController = TextEditingController(text: c?.name ?? '');
    _mobileController = TextEditingController(text: c?.mobileNumber ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
    _contactType = c?.contactType ?? 1;
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text.trim(),
      'mobileNumber': _mobileController.text.trim().isEmpty
          ? null
          : _mobileController.text.trim(),
      'email': _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      'contactType': _contactType,
      'isActive': _isActive,
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    };

    final provider = ref.read(contactsProvider);
    bool success;

    if (_isEditing) {
      success = await provider.updateContact(widget.contact!.id, data);
    } else {
      success = await provider.createContact(data);
    }

    if (mounted) {
      if (success) {
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Failed to update contact' : 'Failed to create contact',
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
    final provider = ref.watch(contactsProvider);

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
          _isEditing ? 'Edit Contact' : 'New Contact',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(label: 'Contact Details', theme: theme),
              SizedBox(height: 12.h),

              _buildTextField(
                controller: _nameController,
                label: 'Name',
                hint: 'e.g. John Doe',
                icon: Icons.person_outline_rounded,
                isDark: isDark,
                theme: theme,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              SizedBox(height: 14.h),

              _buildTextField(
                controller: _mobileController,
                label: 'Mobile Number',
                hint: 'e.g. +91 9876543210',
                icon: Icons.phone_outlined,
                isDark: isDark,
                theme: theme,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 14.h),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'e.g. john@example.com',
                icon: Icons.email_outlined,
                isDark: isDark,
                theme: theme,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20.h),

              _SectionLabel(label: 'Type', theme: theme),
              SizedBox(height: 12.h),

              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _contactTypes.map((type) {
                  final isSelected = _contactType == type.value;
                  return GestureDetector(
                    onTap: () => setState(() => _contactType = type.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20.h),

              _buildTextField(
                controller: _notesController,
                label: 'Notes',
                hint: 'Optional notes about this contact',
                icon: Icons.notes_rounded,
                isDark: isDark,
                theme: theme,
                maxLines: 3,
              ),
              SizedBox(height: 16.h),

              if (_isEditing) ...[
                Row(
                  children: [
                    Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Switch.adaptive(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      activeThumbColor: theme.colorScheme.primary,
                      activeTrackColor:
                          theme.colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],

              SizedBox(height: 20.h),

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: provider.isLoading
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Contact' : 'Add Contact',
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

class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _SectionLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
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
}
