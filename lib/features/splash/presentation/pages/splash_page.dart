import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Animated splash screen shown on app launch.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Navigate to home after 3 seconds
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo container
              Container(
                width: 100.r,
                height: 100.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(28.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 52.r,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.4, 0.4),
                    end: const Offset(1.0, 1.0),
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),

              SizedBox(height: 28.h),

              // App name
              Text(
                'ExpenseTracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 600.ms),

              SizedBox(height: 8.h),

              Text(
                'Smart Money. Simple Life.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms),

              const Spacer(flex: 2),

              // Loading indicator
              SizedBox(
                width: 36.r,
                height: 36.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 1000.ms, duration: 400.ms),

              SizedBox(height: 12.h),

              Text(
                'Loading your finances...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12.sp,
                ),
              )
                  .animate()
                  .fadeIn(delay: 1200.ms, duration: 400.ms),

              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }
}
