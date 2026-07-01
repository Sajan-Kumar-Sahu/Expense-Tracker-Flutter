import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../features/accounts/presentation/providers/accounts_provider.dart';
import '../../../../features/categories/presentation/providers/categories_provider.dart';
import '../../../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../../../features/transactions/presentation/providers/transactions_provider.dart';
import '../../../../routes/app_router.dart';
import '../../domain/entities/settlement_entity.dart';
import '../providers/settlements_provider.dart';

class SettlementDetailsPage extends ConsumerStatefulWidget {
  final String settlementId;

  const SettlementDetailsPage({super.key, required this.settlementId});

  @override
  ConsumerState<SettlementDetailsPage> createState() =>
      _SettlementDetailsPageState();
}

class _SettlementDetailsPageState
    extends ConsumerState<SettlementDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settlementsProvider).loadById(widget.settlementId);
    });
  }

  Future<void> _showPaymentSheet(
      BuildContext context, SettlementEntity settlement) async {
    final accounts = ref.read(accountsProvider).accounts;
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No accounts available')),
      );
      return;
    }

    final amountController = TextEditingController();
    final notesController = TextEditingController();
    String? selectedAccountId = accounts.first.id;
    String? selectedCategoryId;
    DateTime selectedDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final theme = Theme.of(ctx);
          final isDark = theme.brightness == Brightness.dark;
          final isReceivable = settlement.isReceivable;
          final categoryType = isReceivable ? 1 : 2;
          final categories = ref
              .read(categoriesProvider)
              .categories
              .where((c) => c.isActive && c.categoryType == categoryType)
              .toList();

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88,
              ),
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : theme.scaffoldBackgroundColor,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      isReceivable ? 'Record Payment Received' : 'Record Payment Made',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Pending: ${CurrencyFormatter.format(settlement.pendingAmount, showDecimal: true)}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    Text(
                      'Amount (₹)',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6)),
                    ),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Amount is required';
                        }
                        final d = double.tryParse(v.trim());
                        if (d == null || d <= 0) {
                          return 'Enter a valid amount';
                        }
                        if (d > settlement.pendingAmount) {
                          return 'Cannot exceed pending amount';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '0',
                        prefixIcon: Icon(Icons.currency_rupee_rounded,
                            size: 18.r,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4)),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16.w),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                              color: theme.colorScheme.primary, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                              color: theme.colorScheme.error, width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                              color: theme.colorScheme.error, width: 1.5),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.35),
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    Text(
                      'Account',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6)),
                    ),
                    SizedBox(height: 6.h),
                    DropdownButtonFormField<String>(
                      value: selectedAccountId,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                              color: theme.colorScheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                      ),
                      items: accounts
                          .where((a) => a.isActive)
                          .map((a) => DropdownMenuItem(
                                value: a.id,
                                child: Text(a.name),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setModalState(() => selectedAccountId = v),
                      validator: (v) =>
                          v == null ? 'Please select an account' : null,
                    ),
                    SizedBox(height: 14.h),

                    Text(
                      'Category (optional)',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6)),
                    ),
                    SizedBox(height: 6.h),
                    DropdownButtonFormField<String>(
                      value: selectedCategoryId,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                              color: theme.colorScheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        hintText: 'Select category',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.35),
                          fontSize: 14.sp,
                        ),
                      ),
                      hint: Text(
                        'Select category',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.35),
                          fontSize: 14.sp,
                        ),
                      ),
                      items: categories
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setModalState(() => selectedCategoryId = v),
                    ),
                    SizedBox(height: 14.h),

                    Text(
                      'Date',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6)),
                    ),
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 16.r,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4)),
                            SizedBox(width: 8.w),
                            Text(
                              DateFormat('dd MMM yyyy').format(selectedDate),
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    TextFormField(
                      controller: notesController,
                      decoration: InputDecoration(
                        hintText: 'Notes (optional)',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                              color: theme.colorScheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.35),
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final data = {
                            'accountId': selectedAccountId,
                            'amount': double.parse(
                                amountController.text.trim()),
                            'categoryId': selectedCategoryId,
                            'transactionDate': DateTime.utc(selectedDate.year, selectedDate.month, selectedDate.day).toIso8601String(),
                            'notes': notesController.text.trim().isEmpty
                                ? null
                                : notesController.text.trim(),
                          };
                          Navigator.pop(ctx);
                          final provider = ref.read(settlementsProvider);
                          final success = isReceivable
                              ? await provider.receivePayment(
                                  settlement.id, data)
                              : await provider.pay(settlement.id, data);
                          if (context.mounted && success) {
                            unawaited(ref.read(accountsProvider).loadAccounts());
                            unawaited(ref.read(transactionsProvider).loadTransactions());
                            ref.invalidate(dashboardProvider);
                            ref.invalidate(recentTransactionsProvider);
                          }
                          if (context.mounted && !success) {
                            final error = provider.lastError;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    error ?? 'Failed to record payment'),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isReceivable
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isReceivable
                              ? 'Confirm Receipt'
                              : 'Confirm Payment',
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmCancel(
      BuildContext context, SettlementEntity settlement) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        title: const Text('Cancel Settlement'),
        content:
            const Text('Are you sure you want to cancel this settlement?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Cancel Settlement'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final success =
          await ref.read(settlementsProvider).cancel(settlement.id);
      if (context.mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to cancel settlement')),
        );
      }
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, SettlementEntity settlement) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        title: const Text('Delete Settlement'),
        content: const Text(
            'Delete this settlement? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final success = await ref
          .read(settlementsProvider)
          .deleteSettlement(settlement.id);
      if (context.mounted) {
        if (success) {
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete settlement')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = ref.watch(settlementsProvider);
    final settlement = provider.selectedSettlement;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.r),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settlement',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (settlement != null && !settlement.isCompleted && !settlement.isCancelled)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, size: 22.r),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              onSelected: (v) {
                if (v == 'edit') {
                  context.push(AppRouter.editSettlement, extra: settlement);
                }
                if (v == 'cancel') {
                  _confirmCancel(context, settlement);
                }
                if (v == 'delete') {
                  _confirmDelete(context, settlement);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(
                    value: 'cancel', child: Text('Cancel Settlement')),
                if (settlement.isPending)
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : settlement == null
              ? const Center(child: Text('Settlement not found'))
              : _SettlementDetailBody(
                  settlement: settlement,
                  isDark: isDark,
                  theme: theme,
                  onPaymentTap: () =>
                      _showPaymentSheet(context, settlement),
                ),
    );
  }
}

class _SettlementDetailBody extends StatelessWidget {
  final SettlementEntity settlement;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onPaymentTap;

  const _SettlementDetailBody({
    required this.settlement,
    required this.isDark,
    required this.theme,
    required this.onPaymentTap,
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
      settlement.isReceivable ? const Color(0xFF10B981) : const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final progress = settlement.originalAmount > 0
        ? (settlement.paidAmount / settlement.originalAmount).clamp(0.0, 1.0)
        : 0.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _typeColor.withValues(alpha: 0.15),
                  _typeColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: _typeColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        settlement.typeName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: _typeColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        settlement.statusName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  settlement.reason,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  settlement.contactName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: _AmountInfo(
                        label: 'Total',
                        amount: settlement.originalAmount,
                        color: theme.colorScheme.onSurface,
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      child: _AmountInfo(
                        label: 'Paid',
                        amount: settlement.paidAmount,
                        color: const Color(0xFF10B981),
                        theme: theme,
                      ),
                    ),
                    Expanded(
                      child: _AmountInfo(
                        label: 'Pending',
                        amount: settlement.pendingAmount,
                        color: _typeColor,
                        theme: theme,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_typeColor),
                    minHeight: 6.h,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% settled',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.1, end: 0, duration: 400.ms),

          SizedBox(height: 20.h),

          // Details section
          _DetailRow(
            label: 'Contact',
            value: settlement.contactName,
            icon: Icons.person_outline_rounded,
            theme: theme,
            isDark: isDark,
          ),
          if (settlement.dueDate != null)
            _DetailRow(
              label: 'Due Date',
              value: DateFormat('dd MMM yyyy').format(settlement.dueDate!),
              icon: Icons.calendar_today_outlined,
              theme: theme,
              isDark: isDark,
              valueColor: settlement.dueDate!.isBefore(DateTime.now()) &&
                      !settlement.isCompleted
                  ? theme.colorScheme.error
                  : null,
            ),
          _DetailRow(
            label: 'Created',
            value:
                DateFormat('dd MMM yyyy').format(settlement.createdAt),
            icon: Icons.access_time_rounded,
            theme: theme,
            isDark: isDark,
          ),
          if (settlement.notes != null && settlement.notes!.isNotEmpty)
            _DetailRow(
              label: 'Notes',
              value: settlement.notes!,
              icon: Icons.notes_rounded,
              theme: theme,
              isDark: isDark,
            ),

          SizedBox(height: 24.h),

          // Action button
          if (!settlement.isCompleted && !settlement.isCancelled)
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: onPaymentTap,
                icon: Icon(
                  settlement.isReceivable
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 20.r,
                ),
                label: Text(
                  settlement.isReceivable
                      ? 'Record Payment Received'
                      : 'Record Payment Made',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _typeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _AmountInfo extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final ThemeData theme;

  const _AmountInfo({
    required this.label,
    required this.amount,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          CurrencyFormatter.format(amount, showDecimal: true),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ThemeData theme;
  final bool isDark;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              size: 18.r,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? theme.colorScheme.onSurface,
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
