import 'package:expense_tracker/core/utils/app_refresh.dart';
import 'package:expense_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:expense_tracker/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:expense_tracker/features/settings/presentation/providers/user_provider.dart';
import 'package:expense_tracker/features/biometric/presentation/pages/biometric_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/providers/theme_provider.dart';
import '../../../../routes/app_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 26.sp,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.2, end: 0, duration: 400.ms),
                    SizedBox(height: 24.h),

                    // Profile card
                    _ProfileCard(theme: theme)
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 500.ms)
                        .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 500.ms),
                    SizedBox(height: 24.h),

                    // Appearance section
                    _SectionHeader(title: 'Appearance', delay: 200),
                    _SettingsTile(
                      icon: Icons.dark_mode_rounded,
                      iconColor: const Color(0xFF6366F1),
                      title: 'Dark Mode',
                      subtitle: 'Toggle dark/light theme',
                      delay: 250,
                      trailing: Switch.adaptive(
                        value: isDark,
                        activeThumbColor: theme.colorScheme.primary,
                        activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                        onChanged: (_) =>
                            ref.read(themeProvider.notifier).toggle(),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Currency',
                      subtitle: 'Indian Rupee (₹ INR)',
                      delay: 300,
                      onTap: () => _showComingSoon(context, 'Currency Settings'),
                    ),
                    SizedBox(height: 20.h),

                    // Account section
                    _SectionHeader(title: 'Account', delay: 350),
                    _SettingsTile(
                      icon: Icons.person_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      title: 'Profile Settings',
                      subtitle: 'Update name, email & photo',
                      delay: 400,
                      onTap: () => _showComingSoon(context, 'Profile Settings'),
                    ),
                    _SettingsTile(
                      icon: Icons.lock_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Security',
                      subtitle: 'PIN, biometric & password',
                      delay: 450,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BiometricSettingsPage(),
                          ),
                        );
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_rounded,
                      iconColor: const Color(0xFFEF4444),
                      title: 'Notifications',
                      subtitle: 'Manage alerts & reminders',
                      delay: 500,
                      onTap: () => _showComingSoon(context, 'Notifications'),
                    ),
                    SizedBox(height: 20.h),

                    // Data section
                    _SectionHeader(title: 'Data & Privacy', delay: 550),
                    _SettingsTile(
                      icon: Icons.backup_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Backup & Restore',
                      subtitle: 'Cloud sync your expense data',
                      delay: 600,
                      onTap: () => _showComingSoon(context, 'Backup & Restore'),
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_rounded,
                      iconColor: const Color(0xFF64748B),
                      title: 'Privacy Policy',
                      subtitle: 'Read our data policy',
                      delay: 650,
                      onTap: () => _showComingSoon(context, 'Privacy Policy'),
                    ),
                    SizedBox(height: 20.h),

                    // App info
                    _SectionHeader(title: 'About', delay: 700),
                    _SettingsTile(
                      icon: Icons.info_rounded,
                      iconColor: const Color(0xFF0EA5E9),
                      title: 'App Version',
                      subtitle: 'v1.0.0 (Build 1)',
                      delay: 750,
                    ),
                    SizedBox(height: 24.h),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmLogout(context, ref),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(
                              color: theme.colorScheme.error.withValues(alpha: 0.4)),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 400.ms),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      clearAll(ref);
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) context.go(AppRouter.getStarted);
    }
  }
}

class _ProfileCard extends ConsumerWidget {
  final ThemeData theme;
  const _ProfileCard({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      loading: ()=> const SizedBox(),
      error: (error, stack) => const SizedBox(),
      data: (user) {
        final initials = user.fullName
            .split(' ')
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase();

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            const Color(0xFF7C3AED),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfilePage(),
                ),
              );
            },
            child: Icon(
              Icons.edit_rounded,
              color: Colors.white.withValues(alpha: 0.8),
              size: 20.r,
            ),
          )
        ],
      ),
    );
      }
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int delay;

  const _SectionHeader({required this.title, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final int delay;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.delay,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
        leading: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor, size: 20.r),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        trailing: trailing ??
            (onTap != null
                ? Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                    size: 20.r,
                  )
                : null),
        onTap: onTap,
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideX(begin: 0.05, end: 0, delay: Duration(milliseconds: delay), duration: 400.ms);
  }
}
