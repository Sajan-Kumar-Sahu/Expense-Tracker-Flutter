import 'package:expense_tracker/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:expense_tracker/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/api_endpoints.dart';
import 'package:expense_tracker/core/network/api_client.dart';
import 'package:expense_tracker/dependency_injection/injection.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final accountNameProvider =
FutureProvider.family<String, String>((ref, accountId) async {
  final apiClient = locator<ApiClient>();
  try {
    final response = await apiClient.get('${ApiEndpoints.accounts}/$accountId');
    final data = response.data['data'] as Map<String, dynamic>;
    return data['name'] as String? ?? accountId;
  } catch (e) {
    debugPrint('[accountNameProvider] ERROR: $e');
    return accountId;
  }
});

final categoryNameProvider =
FutureProvider.family<String, String>((ref, categoryId) async {
  final apiClient = locator<ApiClient>();
  try {
    final response =
    await apiClient.get('${ApiEndpoints.categories}/$categoryId');
    final data = response.data['data'] as Map<String, dynamic>;
    return data['name'] as String? ?? categoryId;
  } catch (e) {
    debugPrint('[categoryNameProvider] ERROR: $e');
    return categoryId;
  }
});

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class TransactionDetailsPage extends ConsumerStatefulWidget {
  final String transactionId;

  const TransactionDetailsPage({
    super.key,
    required this.transactionId,
  });

  @override
  ConsumerState<TransactionDetailsPage> createState() =>
      _TransactionDetailsPageState();
}

class _TransactionDetailsPageState
    extends ConsumerState<TransactionDetailsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(transactionsProvider).loadTransactionById(widget.transactionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(transactionsProvider);
    final transaction = provider.selectedTransaction;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : transaction == null
          ? _EmptyState()
          : CustomScrollView(
        slivers: [
          // ── Collapsing Hero ───────────────────────────────────
          SliverAppBar(
            expandedHeight: 210.h,
            pinned: true,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: _CircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => context.pop(),
            ),
            actions: [
              _CircleIconButton(
                icon: Icons.edit_outlined,
                onTap: () => context.push(
                  AppRouter.editTransaction,
                  extra: transaction,
                ),
              ),
              SizedBox(width: 6.w),
              _CircleIconButton(
                icon: Icons.delete_outline_rounded,
                onTap: () => _confirmDelete(context, transaction.id),
                isDestructive: true,
              ),
              SizedBox(width: 12.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _HeroSection(
                amount: transaction.amount,
                transactionType: transaction.transactionType,
                date: transaction.transactionDate,
                paidTo: transaction.paidTo,
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding:
              EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 48.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account + Category chips (2-column)
                  Row(
                    children: [
                      Expanded(
                        child: _AccountStatChip(
                            accountId: transaction.accountId),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _CategoryStatChip(
                            categoryId: transaction.categoryId),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Transaction info section
                  _SectionLabel(label: 'Transaction info'),
                  SizedBox(height: 10.h),
                  _DetailCard(
                    children: [
                      _DetailRow(
                        iconData: Icons.swap_horiz_rounded,
                        iconBg: const Color(0xFFEEEDFE),
                        iconColor: const Color(0xFF534AB7),
                        label: 'Type',
                        value: _typeLabel(transaction.transactionType),
                        valueColor:
                        _typeColor(context, transaction.transactionType),
                      ),
                      if (transaction.paidTo.isNotEmpty) ...[
                        _CardDivider(),
                        _DetailRow(
                          iconData: Icons.person_outline_rounded,
                          iconBg: const Color(0xFFE1F5EE),
                          iconColor: const Color(0xFF0F6E56),
                          label: 'Paid to',
                          value: transaction.paidTo,
                        ),
                      ],
                      _CardDivider(),
                      _DetailRow(
                        iconData: Icons.currency_rupee_rounded,
                        iconBg: const Color(0xFFFAEEDA),
                        iconColor: const Color(0xFF854F0B),
                        label: 'Amount',
                        value:
                        '₹${transaction.amount.toStringAsFixed(2)}',
                        valueColor:
                        _typeColor(context, transaction.transactionType),
                      ),
                      if (transaction.transferAccountId != null) ...[
                        _CardDivider(),
                        _DetailRow(
                          iconData: Icons.compare_arrows_rounded,
                          iconBg: const Color(0xFFE6F1FB),
                          iconColor: const Color(0xFF185FA5),
                          label: 'Transfer to',
                          value: transaction.transferAccountId!,
                        ),
                      ],
                    ],
                  ),

                  // Notes card (full-width prose block)
                  if (transaction.notes.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    _SectionLabel(label: 'Notes'),
                    SizedBox(height: 10.h),
                    _NotesCard(notes: transaction.notes),
                  ],

                  SizedBox(height: 24.h),

                  // Timeline section
                  _SectionLabel(label: 'Timeline'),
                  SizedBox(height: 10.h),
                  _DetailCard(
                    children: [
                      _DetailRow(
                        iconData: Icons.calendar_today_outlined,
                        iconBg: const Color(0xFFE6F1FB),
                        iconColor: const Color(0xFF185FA5),
                        label: 'Transaction date',
                        value: DateFormat('dd MMM yyyy')
                            .format(transaction.transactionDate),
                      ),
                      _CardDivider(),
                      _DetailRow(
                        iconData: Icons.access_time_rounded,
                        iconBg: const Color(0xFFF1EFE8),
                        iconColor: const Color(0xFF5F5E5A),
                        label: 'Created at',
                        value: DateFormat('dd MMM yyyy · hh:mm a')
                            .format(transaction.createdAt.toLocal()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _typeLabel(int type) {
    switch (type) {
      case 1: return 'Income';
      case 2: return 'Expense';
      case 3: return 'Transfer';
      default: return 'Unknown';
    }
  }

  Color _typeColor(BuildContext context, int type) {
    switch (type) {
      case 1: return const Color(0xFF3B6D11);
      case 2: return Theme.of(context).colorScheme.error;
      case 3: return Theme.of(context).colorScheme.primary;
      default: return Theme.of(context).colorScheme.onSurface;
    }
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text('Delete transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success =
    await ref.read(transactionsProvider).deleteTransaction(id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Transaction deleted' : 'Failed to delete transaction',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );

    if (success) context.go(AppRouter.home);
  }
}

// ---------------------------------------------------------------------------
// Hero section
// ---------------------------------------------------------------------------

class _HeroSection extends StatelessWidget {
  final double amount;
  final int transactionType;
  final DateTime date;
  final String paidTo;

  const _HeroSection({
    required this.amount,
    required this.transactionType,
    required this.date,
    required this.paidTo,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color amountColor = transactionType == 1
        ? const Color(0xFF10B97F)
        : transactionType == 2
        ? colorScheme.error
        : colorScheme.primary;

    final Color badgeBg = transactionType == 1
        ? const Color(0xFFEAF3DE)
        : transactionType == 2
        ? const Color(0xFFFCEBEB)
        : const Color(0xFFE6F1FB);

    final String sign =
    transactionType == 1 ? '+ ' : transactionType == 2 ? '- ' : '';

    final IconData typeIcon = transactionType == 1
        ? Icons.arrow_downward_rounded
        : transactionType == 2
        ? Icons.arrow_upward_rounded
        : Icons.compare_arrows_rounded;

    final String typeLabel = transactionType == 1
        ? 'Income'
        : transactionType == 2
        ? 'Expense'
        : 'Transfer';

    return Container(
      width: double.infinity,
      color: colorScheme.surface,
      padding: EdgeInsets.fromLTRB(20.w, 90.h, 20.w, 20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type badge pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(typeIcon, size: 12.sp, color: amountColor),
                SizedBox(width: 4.w),
                Text(
                  typeLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: amountColor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Amount
          Text(
            '$sign₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 38.sp,
              fontWeight: FontWeight.w700,
              color: amountColor,
              letterSpacing: -1,
              height: 1,
            ),
          ),

          SizedBox(height: 6.h),

          // Sub-line: paid to · date
          Text(
            [
              if (paidTo.isNotEmpty) paidTo,
              DateFormat('dd MMM yyyy').format(date),
            ].join(' · '),
            style: TextStyle(
              fontSize: 13.sp,
              color: colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Account & Category stat chips (2-col row)
// ---------------------------------------------------------------------------

class _AccountStatChip extends ConsumerWidget {
  final String accountId;
  const _AccountStatChip({required this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncName = ref.watch(accountNameProvider(accountId));
    final name = asyncName.when(
      data: (n) => n,
      loading: () => '…',
      error: (_, __) => accountId,
    );
    return _StatChip(
      label: 'Account',
      value: name,
      iconData: Icons.account_balance_wallet_outlined,
      iconBg: const Color(0xFFEEEDFE),
      iconColor: const Color(0xFF534AB7),
    );
  }
}

class _CategoryStatChip extends ConsumerWidget {
  final String categoryId;
  const _CategoryStatChip({required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncName = ref.watch(categoryNameProvider(categoryId));
    final name = asyncName.when(
      data: (n) => n,
      loading: () => '…',
      error: (_, __) => categoryId,
    );
    return _StatChip(
      label: 'Category',
      value: name,
      iconData: Icons.label_outline_rounded,
      iconBg: const Color(0xFFE1F5EE),
      iconColor: const Color(0xFF0F6E56),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData iconData;
  final Color iconBg;
  final Color iconColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.iconData,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon bubble
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(iconData, size: 18.sp, color: iconColor),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: colorScheme.onSurface.withOpacity(0.45),
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail card + rows
// ---------------------------------------------------------------------------

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
          Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData iconData;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.iconData,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Coloured icon bubble
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(iconData, size: 17.sp, color: iconColor),
          ),
          SizedBox(width: 12.w),
          // Label stacked above value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colorScheme.onSurface.withOpacity(0.45),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0,
      thickness: 0.5,
      indent: 64.w,
      color:
      Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
    );
  }
}

// ---------------------------------------------------------------------------
// Notes card
// ---------------------------------------------------------------------------

class _NotesCard extends StatelessWidget {
  final String notes;
  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: const Color(0xFFF1EFE8),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.notes_rounded,
              size: 17.sp,
              color: const Color(0xFF5F5E5A),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              notes,
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.onSurface.withOpacity(0.75),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Circle icon button (AppBar actions)
// ---------------------------------------------------------------------------

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: isDestructive
              ? colorScheme.error.withOpacity(0.08)
              : colorScheme.surfaceContainerHighest.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: isDestructive
              ? colorScheme.error
              : colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 32.sp,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Transaction not found',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}