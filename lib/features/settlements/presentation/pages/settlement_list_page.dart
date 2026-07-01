import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../routes/app_router.dart';
import '../../domain/entities/settlement_entity.dart';
import '../providers/settlements_provider.dart';

class SettlementListPage extends ConsumerStatefulWidget {
  const SettlementListPage({super.key});

  @override
  ConsumerState<SettlementListPage> createState() =>
      _SettlementListPageState();
}

class _SettlementListPageState extends ConsumerState<SettlementListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _searchController.clear();
    await ref.read(settlementsProvider).loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = ref.watch(settlementsProvider);
    final query = _searchController.text.toLowerCase();

    final receivables = provider.settlements
        .where((s) =>
            s.isReceivable &&
            (s.isPending || s.isPartial) &&
            (query.isEmpty ||
                s.contactName.toLowerCase().contains(query) ||
                s.reason.toLowerCase().contains(query)))
        .toList();

    final payables = provider.settlements
        .where((s) =>
            s.isPayable &&
            (s.isPending || s.isPartial) &&
            (query.isEmpty ||
                s.contactName.toLowerCase().contains(query) ||
                s.reason.toLowerCase().contains(query)))
        .toList();

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
                    'Settlements',
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
                        icon: Icon(Icons.people_outline_rounded, size: 22.r),
                        tooltip: 'Contacts',
                        onPressed: () => context.push(AppRouter.contacts),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_rounded, size: 26.r),
                        tooltip: 'Add Settlement',
                        onPressed: () =>
                            context.push(AppRouter.addSettlement),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // Summary cards
            if (provider.summary != null)
              _SummaryBar(
                summary: provider.summary!,
                theme: theme,
                isDark: isDark,
              ),

            SizedBox(height: 12.h),

            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search settlements...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 20.r,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () => _searchController.clear(),
                          child: Icon(Icons.close_rounded,
                              size: 18.r,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4)),
                        )
                      : null,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
            SizedBox(height: 12.h),

            // Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  labelStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  dividerColor: Colors.transparent,
                  padding: EdgeInsets.all(4.r),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_downward_rounded, size: 14.r),
                          SizedBox(width: 4.w),
                          Text('Receivable (${receivables.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_upward_rounded, size: 14.r),
                          SizedBox(width: 4.w),
                          Text('Payable (${payables.length})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            SizedBox(height: 8.h),

            // Tab content
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _SettlementTab(
                          settlements: receivables,
                          isReceivable: true,
                          onRefresh: _onRefresh,
                          theme: theme,
                          isDark: isDark,
                        ),
                        _SettlementTab(
                          settlements: payables,
                          isReceivable: false,
                          onRefresh: _onRefresh,
                          theme: theme,
                          isDark: isDark,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final SettlementSummaryEntity summary;
  final ThemeData theme;
  final bool isDark;

  const _SummaryBar({
    required this.summary,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'To Receive',
              amount: summary.totalReceivable,
              count: summary.pendingReceivableCount,
              color: const Color(0xFF10B981),
              isDark: isDark,
              theme: theme,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _SummaryCard(
              label: 'To Pay',
              amount: summary.totalPayable,
              count: summary.pendingPayableCount,
              color: const Color(0xFFEF4444),
              isDark: isDark,
              theme: theme,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final int count;
  final Color color;
  final bool isDark;
  final ThemeData theme;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.count,
    required this.color,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            CurrencyFormatter.format(amount, showDecimal: true),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '$count pending',
            style: TextStyle(
              fontSize: 11.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementTab extends StatelessWidget {
  final List<SettlementEntity> settlements;
  final bool isReceivable;
  final Future<void> Function() onRefresh;
  final ThemeData theme;
  final bool isDark;

  const _SettlementTab({
    required this.settlements,
    required this.isReceivable,
    required this.onRefresh,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (settlements.isEmpty) {
      return _EmptyState(
        isReceivable: isReceivable,
        theme: theme,
        onRefresh: onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: theme.colorScheme.primary,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 110.h),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: settlements.length,
        itemBuilder: (context, index) {
          return _SettlementCard(
            settlement: settlements[index],
            index: index,
            theme: theme,
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  final SettlementEntity settlement;
  final int index;
  final ThemeData theme;
  final bool isDark;

  const _SettlementCard({
    required this.settlement,
    required this.index,
    required this.theme,
    required this.isDark,
  });

  Color get _statusColor {
    switch (settlement.status) {
      case 1:
        return const Color(0xFFF59E0B);
      case 2:
        return const Color(0xFF6366F1);
      case 3:
        return const Color(0xFF10B981);
      case 4:
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color get _typeColor =>
      settlement.isReceivable
          ? const Color(0xFF10B981)
          : const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final isOverdue = settlement.dueDate != null &&
        settlement.dueDate!.isBefore(DateTime.now()) &&
        !settlement.isCompleted &&
        !settlement.isCancelled;

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () => context.push(
        AppRouter.settlementDetails,
        extra: settlement.id,
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isOverdue
                ? theme.colorScheme.error.withValues(alpha: 0.5)
                : (isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0)),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    settlement.isReceivable
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: _typeColor,
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settlement.reason,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        settlement.contactName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(settlement.pendingAmount,
                          showDecimal: true),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: _typeColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 7.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        settlement.statusName,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: _statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (settlement.dueDate != null || isOverdue) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12.r,
                    color: isOverdue
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    isOverdue
                        ? 'Overdue · ${DateFormat('dd MMM yyyy').format(settlement.dueDate!)}'
                        : 'Due ${DateFormat('dd MMM yyyy').format(settlement.dueDate!)}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isOverdue
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight:
                          isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(3.r),
              child: LinearProgressIndicator(
                value: settlement.originalAmount > 0
                    ? (settlement.paidAmount / settlement.originalAmount)
                        .clamp(0.0, 1.0)
                    : 0.0,
                backgroundColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.08),
                valueColor:
                    AlwaysStoppedAnimation<Color>(_typeColor),
                minHeight: 4.h,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: index * 50 + 250), duration: 400.ms)
        .slideY(
            begin: 0.08,
            end: 0,
            delay: Duration(milliseconds: index * 50 + 250),
            duration: 400.ms);
  }
}

class _EmptyState extends StatelessWidget {
  final bool isReceivable;
  final ThemeData theme;
  final Future<void> Function() onRefresh;

  const _EmptyState({
    required this.isReceivable,
    required this.theme,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: theme.colorScheme.primary,
      child: ListView(
        children: [
          SizedBox(height: 80.h),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isReceivable
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 64.r,
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
                SizedBox(height: 16.h),
                Text(
                  isReceivable
                      ? 'No receivables yet'
                      : 'No payables yet',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap + to add a settlement',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
