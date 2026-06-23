import 'package:expense_tracker/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:expense_tracker/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/transaction_entity.dart';

/// Full-featured transactions screen with search, filter, and list.
class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  ConsumerState<TransactionListPage> createState() =>
      _TransactionListPageState();
}

class _TransactionListPageState
    extends ConsumerState<TransactionListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'All';
  List<TransactionEntity> _filteredTransactions = [];

  final List<String> _filters = ['All', 'Income', 'Expense'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilter);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(transactionsProvider).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    _searchController.clear();
    _selectedFilter = 'All';

    await ref
        .read(transactionsProvider)
        .refreshTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(transactionsProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    _filteredTransactions =
        provider.transactions.where((t) {
          final query = _searchController.text.toLowerCase();

          final matchesQuery =
              query.isEmpty ||
                  t.party.toLowerCase().contains(query);

          final matchesFilter =
              _selectedFilter == 'All' ||
                  (_selectedFilter == 'Income' &&
                      t.transactionType == 1) ||
                  (_selectedFilter == 'Expense' &&
                      t.transactionType == 2);

          return matchesQuery && matchesFilter;
        }).toList();

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
                    'Transactions',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26.sp,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0, duration: 400.ms),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${_filteredTransactions.length} items',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 20.r,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _applyFilter();
                          },
                          child: Icon(
                            Icons.close_rounded,
                            size: 18.r,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                          ),
                        )
                      : null,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(
                        color: theme.colorScheme.primary, width: 1.5),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0, delay: 150.ms, duration: 400.ms),
            SizedBox(height: 12.h),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedFilter = filter);
                        _applyFilter();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
                .animate()
                .fadeIn(delay: 250.ms, duration: 400.ms),
            SizedBox(height: 16.h),

            // Transaction list
            Expanded(
              child: provider.isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : RefreshIndicator(
                onRefresh: _onRefresh,
                color: theme.colorScheme.primary,
                child: _filteredTransactions.isEmpty
                    ? _EmptyState(theme: theme)
                    : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    0,
                    20.w,
                    110.h,
                  ),
                  physics:
                  const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: _filteredTransactions.length +
                      (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _filteredTransactions.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return _TransactionCard(
                      transaction:
                      _filteredTransactions[index],
                      index: index,
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;
  final int index;

  const _TransactionCard({required this.transaction, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isIncome = transaction.transactionType == 1;

  return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () {
        context.push(
          AppRouter.transactionDetails,
          extra: transaction.id,
        );
      },
      child: Container(
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
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: isIncome
                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                  : _categoryColor(transaction.categoryId).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              _categoryIcon(transaction.categoryId),
              color: isIncome
                  ? const Color(0xFF10B981)
                  : _categoryColor(transaction.categoryId),
              size: 22.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.party.isNotEmpty
                      ? transaction.party
                      : (transaction.transactionType == 1
                          ? 'Income'
                          : transaction.transactionType == 2
                              ? 'Expense'
                              : 'Transfer'),
                  style: TextStyle(
                      fontSize: 14.sp, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: isIncome
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        isIncome ? 'Income' : 'Expense',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: isIncome
                              ? const Color(0xFF10B97F)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      DateFormat('dd MMM yyyy')
                          .format(transaction.transactionDate),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(transaction.amount)}',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: isIncome
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    ),
  )
      .animate()
      .fadeIn(delay: Duration(milliseconds: index * 60 + 300), duration: 400.ms)
      .slideY(
      begin: 0.08,
      end: 0,
      delay: Duration(milliseconds: index * 60 + 300),
      duration: 400.ms);
  }

  IconData _categoryIcon(String categoryId) {
    switch (categoryId) {
      case 'cat_salary':
      case 'cat_freelance':
        return Icons.account_balance_rounded;
      case 'cat_subscription':
        return Icons.subscriptions_rounded;
      case 'cat_food':
        return Icons.restaurant_rounded;
      case 'cat_shopping':
        return Icons.shopping_bag_rounded;
      case 'cat_transport':
        return Icons.directions_car_rounded;
      case 'cat_utility':
        return Icons.bolt_rounded;
      case 'cat_health':
        return Icons.local_hospital_rounded;
      case 'cat_education':
        return Icons.school_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _categoryColor(String categoryId) {
    switch (categoryId) {
      case 'cat_subscription':
        return const Color(0xFF8B5CF6);
      case 'cat_food':
        return const Color(0xFFF59E0B);
      case 'cat_shopping':
        return const Color(0xFFEC4899);
      case 'cat_transport':
        return const Color(0xFF3B82F6);
      case 'cat_utility':
        return const Color(0xFFF97316);
      case 'cat_health':
        return const Color(0xFFEF4444);
      case 'cat_education':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeData theme;
  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64.r,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No transactions found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try a different search or filter',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
