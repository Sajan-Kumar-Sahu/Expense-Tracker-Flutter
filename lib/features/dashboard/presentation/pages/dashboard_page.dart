import 'package:expense_tracker/features/reminders/presentation/providers/notification_provider.dart';
import 'package:expense_tracker/features/settings/presentation/providers/user_provider.dart';
import 'package:expense_tracker/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/providers/nav_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/welcome_section.dart';
import '../widgets/summary_cards_section.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/recent_transactions_section.dart';
import '../widgets/analytics_section.dart';

/// The premium home dashboard with animated financial overview.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
    await Future.wait([
      ref.refresh(dashboardProvider.future),
      ref.refresh(recentTransactionsProvider.future),
    ]);

    await ref.read(notificationProvider).loadNotifications();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _onRefresh(ref),
          displacement: 20,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting + notification/avatar row
                    _HomeAppBar(),
                    SizedBox(height: 20.h),

                    // Welcome section
                    const WelcomeSection(),
                    SizedBox(height: 24.h),

                    // Summary cards
                    const SummaryCardsSection(),
                    SizedBox(height: 28.h),

                    // Quick actions
                    const QuickActionsSection(),
                    SizedBox(height: 28.h),

                    // Recent transactions
                    const RecentTransactionsSection(),
                    SizedBox(height: 28.h),

                    // Analytics preview
                    const AnalyticsSection(),

                    // Bottom padding for the floating nav bar
                    SizedBox(height: 110.h),
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _HomeAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(userProvider);
    final notificationProviderState = ref.watch(notificationProvider);

    return Row(
      children: [
        // Hamburger menu
        GestureDetector(
          onTap: () => mainScaffoldKey.currentState?.openDrawer(),
          child: Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.menu_rounded,
              color: theme.colorScheme.primary,
              size: 22.r,
            ),
          ),
        ),
        const Spacer(),

        // Notification icon
        _IconButton(
          icon: Icons.notifications_outlined,
          badgeCount: notificationProviderState.unreadCount,
          onTap: () => context.push(AppRouter.notificationList),
          theme: theme,
        ),
        SizedBox(width: 10.w),

        // Avatar
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile coming soon')),
          ),
          child: userAsync.when(
            loading: () => CircleAvatar(
              radius: 18.r,
              backgroundColor: theme.colorScheme.primary,
              child: const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
            error: (_, __) => CircleAvatar(
              radius: 18.r,
              backgroundColor: theme.colorScheme.primary,
              child: const Text('?'),
            ),
            data: (user) {
              final initials = user.fullName
                  .split(' ')
                  .map((e) => e[0])
                  .take(2)
                  .join()
                  .toUpperCase();

              return CircleAvatar(
                radius: 18.r,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback onTap;
  final ThemeData theme;

  const _IconButton({
    required this.icon,
    required this.badgeCount,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22.r),
          ),
          if (badgeCount > 0)
            Positioned(
              right: 8.r,
              top: 8.r,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
