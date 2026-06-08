import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../data/mock/mock_data.dart';
import '../../../../routes/app_router.dart';
import '../../domain/entities/account_entity.dart';
import '../providers/accounts_provider.dart';

/// Accounts screen showing real + mock account cards.
class AccountListPage extends ConsumerWidget {
  const AccountListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(accountsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Accounts',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26.sp,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0, duration: 400.ms),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            ref.read(accountsProvider).loadAccounts(),
                        icon: Icon(Icons.refresh_rounded,
                            color: theme.colorScheme.primary, size: 22.r),
                        tooltip: 'Refresh',
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRouter.addAccount),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add_rounded,
                                  color: Colors.white, size: 16.r),
                              SizedBox(width: 4.w),
                              Text(
                                'Add',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Content
            Expanded(
              child: provider.isLoading
                  ? const AppLoader(
                message: 'Loading accounts...',
              )
                  : RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(accountsProvider)
                      .loadAccounts();
                },
                color: theme.colorScheme.primary,
                child: Builder(
                  builder: (context) {
                    final accounts =
                        provider.accounts;

                    final displayAccounts =
                    accounts.isEmpty
                        ? MockData.accounts
                        : accounts;

                    final isMock =
                        accounts.isEmpty;

                    return CustomScrollView(
                      physics:
                      const AlwaysScrollableScrollPhysics(
                        parent:
                        BouncingScrollPhysics(),
                      ),
                      slivers: [
                        if (isMock)
                          SliverToBoxAdapter(
                            child: Container(
                              margin:
                              EdgeInsets.fromLTRB(
                                  20.w,
                                  0,
                                  20.w,
                                  12.h),
                              padding:
                              EdgeInsets.all(12.r),
                              decoration:
                              BoxDecoration(
                                color: theme
                                    .colorScheme
                                    .primary
                                    .withValues(
                                    alpha: 0.08),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                    12.r),
                                border: Border.all(
                                  color: theme
                                      .colorScheme
                                      .primary
                                      .withValues(
                                      alpha:
                                      0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons
                                        .info_outline_rounded,
                                    color: theme
                                        .colorScheme
                                        .primary,
                                    size: 16.r,
                                  ),
                                  SizedBox(
                                      width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Showing mock data — connect your backend to see real accounts.',
                                      style:
                                      TextStyle(
                                        fontSize:
                                        12.sp,
                                        color: theme
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding:
                          EdgeInsets.fromLTRB(
                              20.w,
                              0,
                              20.w,
                              110.h),
                          sliver: SliverList(
                            delegate:
                            SliverChildBuilderDelegate(
                                  (context, index) =>
                                  _AccountCard(
                                    account:
                                    displayAccounts[
                                    index],
                                    index: index,
                                    isEditable:
                                    !isMock,
                                    ref: ref,
                                    context:
                                    context,
                                  ),
                              childCount:
                              displayAccounts
                                  .length,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final AccountEntity account;
  final int index;
  final bool isEditable;
  final WidgetRef ref;
  final BuildContext context;

  const _AccountCard({
    required this.account,
    required this.index,
    required this.isEditable,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isNegative = account.openingBalance < 0;
    final accentColor = _colorForType(account.accountType);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              _iconForType(account.accountType),
              color: accentColor,
              size: 26.r,
            ),
          ),
          SizedBox(width: 14.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    _accountTypeText(account.accountType),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Balance + menu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(account.openingBalance.abs()),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: isNegative
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                ),
              ),
              if (isNegative)
                Text(
                  'Credit Due',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          if (isEditable) ...[
            SizedBox(width: 4.w),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded,
                  size: 20.r,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              onSelected: (value) async {
                if (value == 'edit') {
                  await context.push(AppRouter.editAccount, extra: account);
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Account'),
                      content: Text(
                          'Are you sure you want to delete "${account.name}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final success =  await ref
                        .read(accountsProvider)
                        .deleteAccount(account.id);
                    if (success) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Account deleted successfully',
                          ),
                        ),
                      );
                    }
                  }
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 80 + 200), duration: 500.ms)
        .slideX(
            begin: 0.08,
            end: 0,
            delay: Duration(milliseconds: index * 80 + 200),
            duration: 500.ms);
  }

  IconData _iconForType(int type) {
    switch (type) {
      case 1:
        return Icons.account_balance_rounded;

      case 2:
        return Icons.wallet_rounded;

      case 3:
        return Icons.credit_card_rounded;

      case 4:
        return Icons.account_balance_wallet_rounded;

      default:
        return Icons.wallet_rounded;
    }
  }

  Color _colorForType(int type) {
    switch (type) {
      case 1:
        return const Color(0xFF6366F1);

      case 2:
        return const Color(0xFF10B981);

      case 3:
        return const Color(0xFFEF4444);

      case 4:
        return const Color(0xFFF59E0B);

      default:
        return const Color(0xFF8B5CF6);
    }
  }
  String _accountTypeText(int type) {
    switch (type) {
      case 1:
        return 'Bank';

      case 2:
        return 'Cash';

      case 3:
        return 'Credit Card';

      case 4:
        return 'Wallet';

      default:
        return 'Unknown';
    }
  }
}
