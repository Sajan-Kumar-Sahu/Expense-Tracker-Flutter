import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/navigation/providers/nav_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../features/transactions/domain/entities/transaction_entity.dart';
import '../providers/dashboard_provider.dart';

class RecentTransactionsSection extends ConsumerWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(recentTransactionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 17.sp,
              ),
            ),
            TextButton(
              onPressed: () => ref.read(navProvider.notifier).state = 1,
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        transactionsAsync.when(
          loading: () => _TransactionsSkeleton(),
          error: (_, __) => Center(
            child: Text(
              'Could not load transactions.',
              style: TextStyle(
                fontSize: 13.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          data: (transactions) {
            if (transactions.isEmpty) {
              return Center(
                child: Text(
                  'No transactions yet.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              );
            }
            return Column(
              children: transactions.asMap().entries.map((entry) {
                return _TransactionListItem(
                  transaction: entry.value,
                  index: entry.key,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _TransactionsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shimmerColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Column(
      children: List.generate(
        3,
        (i) => Container(
          margin: EdgeInsets.only(bottom: 10.h),
          height: 68.h,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final TransactionEntity transaction;
  final int index;

  const _TransactionListItem({
    required this.transaction,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isIncome = transaction.isIncome;
    final title = transaction.paidTo.isNotEmpty
        ? transaction.paidTo
        : (transaction.notes.isNotEmpty ? transaction.notes : (isIncome ? 'Income' : 'Expense'));

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: isIncome
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : _categoryColor(transaction.categoryId).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _categoryIcon(transaction.categoryId, isIncome),
              color: isIncome
                  ? const Color(0xFF10B981)
                  : _categoryColor(transaction.categoryId),
              size: 22.r,
            ),
          ),
          SizedBox(width: 12.w),

          // Description + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  DateFormat('dd MMM yyyy').format(transaction.transactionDate),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(transaction.amount)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: index * 80 + 500), duration: 400.ms)
        .slideX(
            begin: 0.1,
            end: 0,
            delay: Duration(milliseconds: index * 80 + 500),
            duration: 400.ms);
  }

  IconData _categoryIcon(String categoryId, bool isIncome) {
    if (isIncome) return Icons.account_balance_rounded;
    switch (categoryId.toLowerCase()) {
      case _ when categoryId.contains('food') || categoryId.contains('grocery'):
        return Icons.restaurant_rounded;
      case _ when categoryId.contains('shop'):
        return Icons.shopping_bag_rounded;
      case _ when categoryId.contains('transport') || categoryId.contains('travel'):
        return Icons.directions_car_rounded;
      case _ when categoryId.contains('utility') || categoryId.contains('bill'):
        return Icons.bolt_rounded;
      case _ when categoryId.contains('health') || categoryId.contains('medical'):
        return Icons.local_hospital_rounded;
      case _ when categoryId.contains('education') || categoryId.contains('course'):
        return Icons.school_rounded;
      case _ when categoryId.contains('subscri'):
        return Icons.subscriptions_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _categoryColor(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case _ when categoryId.contains('food') || categoryId.contains('grocery'):
        return const Color(0xFFF59E0B);
      case _ when categoryId.contains('shop'):
        return const Color(0xFFEC4899);
      case _ when categoryId.contains('transport') || categoryId.contains('travel'):
        return const Color(0xFF3B82F6);
      case _ when categoryId.contains('utility') || categoryId.contains('bill'):
        return const Color(0xFFF97316);
      case _ when categoryId.contains('health') || categoryId.contains('medical'):
        return const Color(0xFFEF4444);
      case _ when categoryId.contains('education') || categoryId.contains('course'):
        return const Color(0xFF6366F1);
      case _ when categoryId.contains('subscri'):
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
