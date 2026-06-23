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
  final _passwordController = TextEditingController();
  final _mobileFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _showMobileError = false;
  bool _showPasswordError = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _mobileFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool get _isMobileValid =>
      RegExp(r'^\d{10}$').hasMatch(_mobileController.text.trim());

  bool get _isPasswordValid => _passwordController.text.length >= 4;

  Future<void> _login() async {
    setState(() {
      _showMobileError = !_isMobileValid;
      _showPasswordError = !_isPasswordValid;
    });

    if (!_isMobileValid || !_isPasswordValid) return;

    _mobileFocus.unfocus();
    _passwordFocus.unfocus();

    final success = await ref.read(authProvider.notifier).login(
          _mobileController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      await refreshAll(ref);
      if (!mounted) return;
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

    return Scaffold(
      body: Stack(
        children: [
          // Gradient top section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 0.38.sh,
            child: const _GradientHeader(),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top branding area
                SizedBox(
                  height: 0.28.sh,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72.r,
                          height: 72.r,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 38.r,
                            color: Colors.white,
                          ),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0.5, 0.5),
                              duration: 600.ms,
                              curve: Curves.elasticOut,
                            ),
                        SizedBox(height: 16.h),
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 500.ms)
                            .slideY(begin: 0.3, end: 0, delay: 200.ms),
                        SizedBox(height: 4.h),
                        Text(
                          'Sign in to continue',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13.sp,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 350.ms, duration: 500.ms),
                      ],
                    ),
                  ),
                ),

                // Card
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32.r),
                        topRight: Radius.circular(32.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mobile number field
                          _FieldLabel(label: 'Mobile Number')
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 400.ms),
                          SizedBox(height: 8.h),
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
                                FocusScope.of(context).requestFocus(_passwordFocus),
                            style: TextStyle(fontSize: 15.sp),
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
                                  duration: 400.ms),

                          SizedBox(height: 20.h),

                          // Password field
                          _FieldLabel(label: 'Password')
                              .animate()
                              .fadeIn(delay: 500.ms, duration: 400.ms),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onChanged: (_) =>
                                setState(() => _showPasswordError = false),
                            onSubmitted: (_) => _login(),
                            style: TextStyle(fontSize: 15.sp),
                            decoration: _inputDecoration(
                              context: context,
                              isDark: isDark,
                              hintText: 'Enter your password',
                              prefixIcon: Icons.lock_outline_rounded,
                              hasError: _showPasswordError,
                              errorText: _showPasswordError
                                  ? 'Password must be at least 4 characters'
                                  : null,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20.r,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 550.ms, duration: 400.ms)
                              .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  delay: 550.ms,
                                  duration: 400.ms),

                          SizedBox(height: 32.h),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 54.h,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.35),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: 22.r,
                                      height: 22.r,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 650.ms, duration: 400.ms),
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
