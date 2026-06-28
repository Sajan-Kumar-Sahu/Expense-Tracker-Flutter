import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/biometric_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _isAnimatingOut = false;

  @override
  void initState() {
    super.initState();
    // Proactively trigger native authentication dialog once the layout is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerAuthentication();
    });
  }

  Future<void> _triggerAuthentication() async {
    if (_isAnimatingOut) return;

    final success = await ref.read(biometricProvider.notifier).authenticate();
    if (success && mounted) {
      setState(() {
        _isAnimatingOut = true;
      });
      // Play a smooth exit animation before dismissing the lock screen overlay
      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) {
        ref.read(biometricProvider.notifier).unlock();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final biometricState = ref.watch(biometricProvider);

    Widget screenBody = Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: PopScope(
            canPop: false, // Disables dismissal via Android hardware back button
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // App Wallet Logo
                  Container(
                    width: 84.r,
                    height: 84.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 44.r,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.6, 0.6),
                        duration: 800.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 400.ms),

                  SizedBox(height: 24.h),

                  // App Title
                  Text(
                    'ArthiqHQ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, delay: 200.ms),

                  SizedBox(height: 8.h),

                  // Subtext
                  Text(
                    'Authenticate to continue',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 500.ms),

                  const Spacer(flex: 3),

                  // Unlock Button
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: biometricState.isAuthenticating
                          ? null
                          : _triggerAuthentication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF3730A3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: biometricState.isAuthenticating
                          ? SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF3730A3),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_open_rounded, size: 20.r),
                                SizedBox(width: 8.w),
                                Text(
                                  'Unlock App',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, delay: 500.ms),

                  SizedBox(height: 36.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (_isAnimatingOut) {
      screenBody = screenBody
          .animate()
          .fadeOut(duration: 350.ms)
          .scale(end: const Offset(1.05, 1.05), duration: 350.ms, curve: Curves.easeOutCubic);
    }

    return screenBody;
  }
}
