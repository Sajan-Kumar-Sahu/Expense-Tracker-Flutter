import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/app_router.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

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
            children: [
              const Spacer(flex: 2),

              // Logo
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
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
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
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 500.ms),

              SizedBox(height: 28.h),

              // App name
              Text(
                'ArthiqHQ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 600.ms),

              SizedBox(height: 8.h),

              Text(
                'Smart Money. Simple Life.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms),

              SizedBox(height: 48.h),

              // Feature highlights
              ..._features.asMap().entries.map((entry) {
                return _FeatureRow(
                  icon: entry.value.$1,
                  title: entry.value.$2,
                  subtitle: entry.value.$3,
                  delay: 600 + entry.key * 120,
                );
              }),

              const Spacer(flex: 3),

              // CTA Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRouter.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF3730A3),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 1000.ms, duration: 500.ms)
                  .slideY(begin: 0.4, end: 0, delay: 1000.ms, duration: 500.ms),

              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }

  static const _features = [
    (
      Icons.bar_chart_rounded,
      'Track Every Rupee',
      'Categorise income & expenses effortlessly',
    ),
    (
      Icons.insights_rounded,
      'Smart Analytics',
      'Visualise spending patterns at a glance',
    ),
    (
      Icons.lock_rounded,
      'Secure & Private',
      'Your data, protected with PIN access',
    ),
  ];
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int delay;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 500.ms)
        .slideX(begin: -0.1, end: 0, delay: Duration(milliseconds: delay), duration: 500.ms);
  }
}
