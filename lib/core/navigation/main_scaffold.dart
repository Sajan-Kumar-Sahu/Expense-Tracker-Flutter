import 'package:expense_tracker/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'app_drawer.dart';
import 'providers/nav_provider.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/transactions/presentation/pages/transaction_list_page.dart';
import '../../features/accounts/presentation/pages/account_list_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/categories/presentation/pages/category_list_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Nav destination model
// ─────────────────────────────────────────────────────────────────────────────
class _NavDest {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  const _NavDest({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

const _kDestinations = [
  _NavDest(
    activeIcon: Icons.home_rounded,
    inactiveIcon: Icons.home_outlined,
    label: 'Home',
  ),
  _NavDest(
    activeIcon: Icons.receipt_long_rounded,
    inactiveIcon: Icons.receipt_long_outlined,
    label: 'Transactions',
  ),
  _NavDest(
    activeIcon: Icons.account_balance_wallet_rounded,
    inactiveIcon: Icons.account_balance_wallet_outlined,
    label: 'Accounts',
  ),
  _NavDest(
    activeIcon: Icons.settings_rounded,
    inactiveIcon: Icons.settings_outlined,
    label: 'Settings',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Root scaffold
// ─────────────────────────────────────────────────────────────────────────────
class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fabController;
  late final Animation<double> _fabScale;

  static const List<Widget> _pages = [
    DashboardPage(),
    TransactionListPage(),
    AccountListPage(),
    SettingsPage(),
    CategoryListPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _fabScale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navProvider);
    final theme = Theme.of(context);

    return Scaffold(
      key: mainScaffoldKey,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // ── Page content ────────────────────────────────────────────────
          IndexedStack(index: currentIndex, children: _pages),

          // ── Bottom nav + FAB pinned to bottom ────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomSection(
              currentIndex: currentIndex,
              theme: theme,
              fabScale: _fabScale,
              fabController: _fabController,
              onItemTap: (i) => ref.read(navProvider.notifier).state = i,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Outer stack: FAB floats above the bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomSection extends StatelessWidget {
  final int currentIndex;
  final ThemeData theme;
  final Animation<double> fabScale;
  final AnimationController fabController;
  final ValueChanged<int> onItemTap;

  const _BottomSection({
    required this.currentIndex,
    required this.theme,
    required this.fabScale,
    required this.fabController,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        // ── Nav bar ──────────────────────────────────────────────────────
        _NavBar(
          currentIndex: currentIndex,
          theme: theme,
          onItemTap: onItemTap,
        ),

        // ── FAB centered, overlapping the top edge of the bar ────────────
        // Only visible on the Home/Dashboard tab (index 0)
        if (currentIndex == 0)
          Positioned(
            top: -28.r,
            child: _GradientFab(
              scale: fabScale,
              controller: fabController,
              theme: theme,
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The full-width, border-less nav bar
// ─────────────────────────────────────────────────────────────────────────────
class _NavBar extends StatelessWidget {
  final int currentIndex;
  final ThemeData theme;
  final ValueChanged<int> onItemTap;

  const _NavBar({
    required this.currentIndex,
    required this.theme,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    // Surface colour — no border, just a soft upward shadow for depth.
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;

    return Container(
      // Extra top padding creates visual breathing room above the items
      // and gives the FAB space to overlap without covering them.
      padding: EdgeInsets.only(top: 18.h),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.55)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Row(
            children: List.generate(
              _kDestinations.length,
              (i) => Expanded(
                child: _NavItem(
                  dest: _kDestinations[i],
                  isActive: currentIndex == i,
                  theme: theme,
                  isDark: isDark,
                  onTap: () => onItemTap(i),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual nav item
//  Active  → tinted pill around icon  +  bold coloured label
//  Inactive → plain icon  +  muted label
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final _NavDest dest;
  final bool isActive;
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.dest,
    required this.isActive,
    required this.theme,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    final muted = isDark ? const Color(0xFF4A5568) : const Color(0xFFB0B7C3);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Icon inside animated tinted pill ──────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: isActive
                  ? primary.withValues(alpha: isDark ? 0.20 : 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: child,
              ),
              child: Icon(
                isActive ? dest.activeIcon : dest.inactiveIcon,
                key: ValueKey(isActive),
                size: 23.r,
                color: isActive ? primary : muted,
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // ── Label ─────────────────────────────────────────────────────
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? primary : muted,
              letterSpacing: isActive ? 0.1 : 0,
            ),
            child: Text(
              dest.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(height: 2.h),

          // ── Active dot indicator ───────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            width: isActive ? 18.w : 0,
            height: 3.h,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient FAB with breathing pulse ring
// ─────────────────────────────────────────────────────────────────────────────
class _GradientFab extends StatefulWidget {
  final Animation<double> scale;
  final AnimationController controller;
  final ThemeData theme;

  const _GradientFab({
    required this.scale,
    required this.controller,
    required this.theme,
  });

  @override
  State<_GradientFab> createState() => _GradientFabState();
}

class _GradientFabState extends State<_GradientFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.theme.colorScheme.primary;

    return GestureDetector(
      onTapDown: (_) => widget.controller.forward(),
      onTapUp: (_) {
        widget.controller.reverse();
        context.push(
          AppRouter.addTransaction,
        );
      },
      onTapCancel: () => widget.controller.reverse(),
      child: ScaleTransition(
        scale: widget.scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Breathing glow ring
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 60.r,
                height: 60.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.14),
                ),
              ),
            ),
            // Gradient circle button
            Container(
              width: 50.r,
              height: 50.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    primary,
                    Color.lerp(primary, const Color(0xFF7C3AED), 0.65)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(Icons.add_rounded, color: Colors.white, size: 26.r),
            ),
          ],
        ),
      ),
    );
  }
}
