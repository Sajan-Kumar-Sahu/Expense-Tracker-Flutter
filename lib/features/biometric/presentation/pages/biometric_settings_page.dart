import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/biometric_timeout.dart';
import '../providers/biometric_provider.dart';

class BiometricSettingsPage extends ConsumerStatefulWidget {
  const BiometricSettingsPage({super.key});

  @override
  ConsumerState<BiometricSettingsPage> createState() => _BiometricSettingsPageState();
}

class _BiometricSettingsPageState extends ConsumerState<BiometricSettingsPage> {
  bool _isToggling = false;

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  Future<void> _onToggleChanged(bool value) async {
    if (_isToggling) return;
    setState(() => _isToggling = true);

    try {
      final notifier = ref.read(biometricProvider.notifier);
      if (value) {
        final error = await notifier.enableBiometric();
        if (error != null) {
          _showSnackBar(error, isError: true);
        } else {
          _showSnackBar('Biometric authentication enabled successfully.');
        }
      } else {
        final success = await notifier.disableBiometric();
        if (success) {
          _showSnackBar('Biometric authentication disabled successfully.');
        } else {
          _showSnackBar('Authentication failed. Biometric authentication remains enabled.', isError: true);
        }
      }
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  Future<void> _testAuthentication() async {
    final notifier = ref.read(biometricProvider.notifier);
    final success = await notifier.testAuthentication();
    if (success) {
      _showSnackBar('Authentication successful! Biometrics are working correctly.');
    } else {
      _showSnackBar('Authentication failed or canceled.', isError: true);
    }
  }

  void _showTimeoutPicker() {
    final state = ref.read(biometricProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
                child: Text(
                  'Select Timeout Duration',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              ...BiometricTimeout.values.map((timeout) {
                final isSelected = timeout == state.timeout;
                return ListTile(
                  title: Text(
                    timeout.label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: theme.colorScheme.primary,
                          size: 20.r,
                        )
                      : null,
                  onTap: () {
                    ref.read(biometricProvider.notifier).updateTimeout(timeout);
                    Navigator.pop(context);
                  },
                );
              }),
              SizedBox(height: 12.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(biometricProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Biometric Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header Card
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security_rounded,
                        color: theme.colorScheme.primary,
                        size: 24.r,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Secure Your Finances',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Use fingerprint, Face ID, or device PIN to protect your app access. When active, you will be prompted to authenticate when opening the application or after returning from the background.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms),

            SizedBox(height: 24.h),

            // Section 1 Header
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
              child: Text(
                'CONFIGURATION',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            // Settings Tile Options
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  // Enable Switch
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.fingerprint_rounded,
                        color: theme.colorScheme.primary,
                        size: 22.r,
                      ),
                    ),
                    title: Text(
                      'Biometric Authentication',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Require security lock on launch',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    trailing: _isToggling
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Switch.adaptive(
                            value: state.isEnabled,
                            activeThumbColor: theme.colorScheme.primary,
                            activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                            onChanged: _onToggleChanged,
                          ),
                  ),

                  const Divider(),

                  // Capability Status
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: const Icon(
                        Icons.devices_other_rounded,
                        color: Color(0xFF10B981),
                        size: 22,
                      ),
                    ),
                    title: Text(
                      'Authentication Method',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      state.supportedMethod,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: state.isHardwareSupported
                            ? const Color(0xFF10B981)
                            : theme.colorScheme.error,
                      ),
                    ),
                  ),

                  if (state.isEnabled) ...[
                    const Divider(),

                    // Timeout settings Tile
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: const Icon(
                          Icons.timelapse_rounded,
                          color: Color(0xFFF59E0B),
                          size: 22,
                        ),
                      ),
                      title: Text(
                        'Authentication Timeout',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        state.timeout.label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                        size: 20.r,
                      ),
                      onTap: _showTimeoutPicker,
                    ),
                  ],
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0, delay: 150.ms, duration: 400.ms),

            if (state.isEnabled) ...[
              SizedBox(height: 24.h),

              // Section 2 Header
              Padding(
                padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
                child: Text(
                  'ACTIONS',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              // Action buttons card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: _testAuthentication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(Icons.fingerprint_rounded, size: 20.r),
                    label: Text(
                      'Test Authentication',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, delay: 250.ms, duration: 400.ms),
            ],
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
