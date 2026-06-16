import 'package:expense_tracker/features/settings/presentation/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'providers/nav_provider.dart';
import '../../data/mock/mock_data.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _DrawerHeader(isDark: isDark, theme: theme),
            SizedBox(height: 8.h),

            // Navigation items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    index: 0,
                    ref: ref,
                    context: context,
                  ),
                  _DrawerItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'Transactions',
                    index: 1,
                    ref: ref,
                    context: context,
                  ),
                  _DrawerItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Accounts',
                    index: 2,
                    ref: ref,
                    context: context,
                  ),
                  _DrawerItem(
                    icon: Icons.pie_chart_rounded,
                    label: 'Reports',
                    index: -1,
                    ref: ref,
                    context: context,
                    comingSoon: true,
                  ),
                  _DrawerItem(
                    icon: Icons.category_rounded,
                    label: 'Categories',
                    index: 4,
                    ref: ref,
                    context: context,
                  ),
                  _DrawerItem(
                    icon: Icons.savings_rounded,
                    label: 'Budgets',
                    index: -1,
                    ref: ref,
                    context: context,
                    comingSoon: true,
                  ),
                  Divider(height: 32.h, indent: 8.w, endIndent: 8.w),
                  _DrawerItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    index: 3,
                    ref: ref,
                    context: context,
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    index: -1,
                    ref: ref,
                    context: context,
                    comingSoon: true,
                  ),
                ],
              ),
            ),

            // Logout button
            Padding(
              padding: EdgeInsets.all(16.r),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout coming soon')),
                    );
                  },
                  icon: Icon(Icons.logout_rounded, size: 18.r),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.4)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends ConsumerWidget {
  final bool isDark;
  final ThemeData theme;

  const _DrawerHeader({
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      loading: () => Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withBlue(230),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SizedBox(height: 100.h),
      ),

      error: (_, __) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withBlue(230),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 28.r,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'User',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      data: (user) {
        final initials = user.fullName
            .trim()
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase();

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withBlue(230),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30.r,
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
              SizedBox(height: 12.h),
              Text(
                user.fullName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                user.email,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final WidgetRef ref;
  final BuildContext context;
  final bool comingSoon;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.ref,
    required this.context,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = ref.watch(navProvider);
    final isActive = !comingSoon && index == currentIndex;

    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        leading: Icon(
          icon,
          color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 22.r,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? theme.colorScheme.primary : null,
          ),
        ),
        trailing: comingSoon
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Soon',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
        onTap: () {
          if (comingSoon) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label coming soon')),
            );
            return;
          }
          Navigator.pop(context);
          ref.read(navProvider.notifier).state = index;
        },
      ),
    );
  }
}
