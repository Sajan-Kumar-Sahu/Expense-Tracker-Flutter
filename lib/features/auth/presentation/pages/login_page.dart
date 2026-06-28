import 'package:expense_tracker/core/widgets/animated_pin_input.dart';
import 'package:expense_tracker/features/biometric/presentation/providers/biometric_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_refresh.dart';
import '../../../../routes/app_router.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _mobileController = TextEditingController();
  final _pinController = TextEditingController();
  final _mobileFocus = FocusNode();

  bool _showMobileError = false;
  String _pin = '';
  bool _showPinError = false;
  @override
  void dispose() {
    _mobileController.dispose();
    _pinController.dispose();
    _mobileFocus.dispose();
    super.dispose();
  }

  bool get _isMobileValid =>
      RegExp(r'^\d{10}$').hasMatch(_mobileController.text.trim());

  bool get _isPinValid => _pin.length == 4;

  Future<void> _login() async {
    setState(() {
      _showMobileError = !_isMobileValid;
      _showPinError = !_isPinValid;
    });

    if (!_isMobileValid || !_isPinValid) return;

    _mobileFocus.unfocus();
    FocusScope.of(context).unfocus();

    final success = await ref.read(authProvider.notifier).login(
          _mobileController.text.trim(),
          _pin,
        );

    if (!mounted) return;

    if (success) {
      await refreshAll(ref);
      if (!mounted) return;
      ref.read(biometricProvider.notifier).unlock();
      context.go(AppRouter.home);
    } else {
      final authState = ref.read(authProvider);
      final message =
          authState is AuthError ? authState.message : 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Gradient background — slightly taller than branding area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 0.44.sh,
            child: const _GradientHeader(),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Branding — vertically centered in gradient area ───────
                SizedBox(
                  height: 0.40.sh - topPad,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Container(
                        width: 52.r,
                        height: 52.r,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 28.r,
                          color: Colors.white,
                        ),
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          ),
                      SizedBox(height: 10.h),
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 500.ms)
                          .slideY(begin: 0.3, end: 0, delay: 200.ms),
                      SizedBox(height: 2.h),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12.sp,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 350.ms, duration: 500.ms),
                    ],
                  ),
                ),
                ),

                // ── Card ─────────────────────────────────────────────────
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28.r),
                        topRight: Radius.circular(28.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mobile number
                          const _FieldLabel(label: 'Mobile Number')
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 400.ms),
                          SizedBox(height: 6.h),
                          TextField(
                            controller: _mobileController,
                            focusNode: _mobileFocus,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            maxLength: 10,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (_) =>
                                setState(() => _showMobileError = false),
                            onSubmitted: (_) =>
                                FocusScope.of(context).nextFocus(),
                            style: TextStyle(fontSize: 14.sp),
                            decoration: _inputDecoration(
                              context: context,
                              isDark: isDark,
                              hintText: '10-digit mobile number',
                              prefixIcon: Icons.phone_outlined,
                              hasError: _showMobileError,
                              errorText: _showMobileError
                                  ? 'Enter a valid 10-digit mobile number'
                                  : null,
                              counterText: '',
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 450.ms, duration: 400.ms)
                              .slideY(
                                begin: 0.1,
                                end: 0,
                                delay: 450.ms,
                                duration: 400.ms,
                              ),

                          SizedBox(height: 16.h),

                          // PIN
                          const _FieldLabel(label: 'PIN')
                              .animate()
                              .fadeIn(delay: 500.ms, duration: 400.ms),
                          SizedBox(height: 8.h),
                          AnimatedPinInput(
                            onChanged: (value) {
                              setState(() {
                                _pin = value;
                                _showPinError = false;
                              });
                            },
                            onCompleted: (value) {
                              _pin = value;
                              _login();
                            },
                          )
                              .animate()
                              .fadeIn(delay: 550.ms)
                              .slideY(begin: 0.1, end: 0),
                          SizedBox(height: 8.h),
                          Center(
                            child: Text(
                              'Enter your 4-digit PIN',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                          if (_showPinError)
                            Padding(
                              padding: EdgeInsets.only(top: 6.h),
                              child: Center(
                                child: Text(
                                  'Please enter a valid PIN',
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ),

                          SizedBox(height: 24.h),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: isLoading ||
                                      !_isMobileValid ||
                                      !_isPinValid
                                  ? null
                                  : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: theme
                                    .colorScheme.primary
                                    .withValues(alpha: 0.35),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: 20.r,
                                      height: 20.r,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ).animate().fadeIn(delay: 650.ms, duration: 400.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required BuildContext context,
    required bool isDark,
    required String hintText,
    required IconData prefixIcon,
    required bool hasError,
    String? errorText,
    String? counterText,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hintText,
      counterText: counterText,
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
        fontSize: 14.sp,
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: 20.r,
        color: hasError ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
      suffixIcon: suffixIcon,
      errorText: errorText,
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(
          color:
              isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide:
            BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide:
            BorderSide(color: theme.colorScheme.error, width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _GradientHeader extends StatelessWidget {
  const _GradientHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF3730A3),
            Color(0xFF6366F1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
