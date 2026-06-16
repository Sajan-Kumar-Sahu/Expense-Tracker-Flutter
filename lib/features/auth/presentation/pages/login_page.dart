import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/app_router.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  String _pin = '';
  bool _isEmailValid = false;
  bool _showEmailError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    setState(() {
      _isEmailValid = _validateEmail(value);
      _showEmailError = false;
    });
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
  }

  void _onDigitTap(String digit) {
    if (_pin.length >= 4) return;
    HapticFeedback.lightImpact();
    setState(() => _pin += digit);

    // Auto-submit when PIN is complete and email is valid
    if (_pin.length == 4 && _isEmailValid) {
      _login();
    }
  }

  void _onDeleteTap() {
    if (_pin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _onClearTap() {
    if (_pin.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() => _pin = '');
  }

  Future<void> _login() async {
    if (!_isEmailValid) {
      setState(() => _showEmailError = true);
      return;
    }
    if (_pin.length < 4) return;

    _emailFocus.unfocus();

    final success = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _pin,
        );

    if (!mounted) return;

    if (success) {
      context.go(AppRouter.home);
    } else {
      setState(() => _pin = '');
      final authState = ref.read(authProvider);
      final message =
          authState is AuthError ? authState.message : 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r)),
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
            height: 0.42.sh,
            child: const _GradientHeader(),
          ),

          // Scrollable content
          SafeArea(
            child: Column(
              children: [
                // Top branding area
                SizedBox(
                  height: 0.32.sh,
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
                    child: Column(
                      children: [
                        // Scrollable inputs + numpad
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email field
                                Text(
                                  'Email Address',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                    letterSpacing: 0.5,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 400.ms, duration: 400.ms),
                                SizedBox(height: 8.h),
                                TextField(
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  onChanged: _onEmailChanged,
                                  onSubmitted: (_) => _emailFocus.unfocus(),
                                  style: TextStyle(fontSize: 15.sp),
                                  decoration: InputDecoration(
                                    hintText: 'you@example.com',
                                    hintStyle: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.35),
                                      fontSize: 14.sp,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      size: 20.r,
                                      color: _showEmailError
                                          ? theme.colorScheme.error
                                          : theme.colorScheme.primary,
                                    ),
                                    errorText: _showEmailError
                                        ? 'Enter a valid email address'
                                        : null,
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.outline
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.error,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 450.ms, duration: 400.ms)
                                    .slideY(
                                        begin: 0.1,
                                        end: 0,
                                        delay: 450.ms,
                                        duration: 400.ms),

                                SizedBox(height: 24.h),

                                // PIN label
                                Text(
                                  'Enter 4-Digit PIN',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                    letterSpacing: 0.5,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 550.ms, duration: 400.ms),

                                SizedBox(height: 14.h),

                                // PIN dots
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(4, (i) {
                                    final filled = i < _pin.length;
                                    return AnimatedContainer(
                                      duration: 200.ms,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      width: filled ? 20.r : 16.r,
                                      height: filled ? 20.r : 16.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: filled
                                            ? theme.colorScheme.primary
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: filled
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.3),
                                          width: 2,
                                        ),
                                        boxShadow: filled
                                            ? [
                                                BoxShadow(
                                                  color: theme
                                                      .colorScheme.primary
                                                      .withValues(alpha: 0.4),
                                                  blurRadius: 8,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    );
                                  }),
                                )
                                    .animate()
                                    .fadeIn(delay: 600.ms, duration: 400.ms),

                                SizedBox(height: 20.h),

                                // Number pad
                                _NumPad(
                                  onDigit: _onDigitTap,
                                  onDelete: _onDeleteTap,
                                  onClear: _onClearTap,
                                  isLoading: isLoading,
                                )
                                    .animate()
                                    .fadeIn(delay: 650.ms, duration: 400.ms)
                                    .slideY(
                                        begin: 0.1,
                                        end: 0,
                                        delay: 650.ms,
                                        duration: 400.ms),
                              ],
                            ),
                          ),
                        ),

                        // Login button — pinned outside scroll, always visible
                        Padding(
                          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
                          child: SizedBox(
                            width: double.infinity,
                            height: 54.h,
                            child: ElevatedButton(
                              onPressed: isLoading ||
                                      _pin.length < 4 ||
                                      !_isEmailValid
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
                          ).animate().fadeIn(delay: 750.ms, duration: 400.ms),
                        ),
                      ],
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

class _NumPad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final bool isLoading;

  const _NumPad({
    required this.onDigit,
    required this.onDelete,
    required this.onClear,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget numKey(String label) {
      return Expanded(
        child: GestureDetector(
          onTap: isLoading ? null : () => onDigit(label),
          child: AnimatedContainer(
            duration: 100.ms,
            margin: EdgeInsets.all(5.r),
            height: 50.h,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget deleteKey() {
      return Expanded(
        child: GestureDetector(
          onTap: isLoading ? null : onDelete,
          child: Container(
            margin: EdgeInsets.all(5.r),
            height: 50.h,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.backspace_outlined,
                size: 19.r,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    Widget clearKey() {
      return Expanded(
        child: GestureDetector(
          onTap: isLoading ? null : onClear,
          child: Container(
            margin: EdgeInsets.all(5.r),
            height: 50.h,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Center(
              child: Text(
                'C',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(children: ['1', '2', '3'].map(numKey).toList()),
        Row(children: ['4', '5', '6'].map(numKey).toList()),
        Row(children: ['7', '8', '9'].map(numKey).toList()),
        Row(children: [clearKey(), numKey('0'), deleteKey()]),
      ],
    );
  }
}
