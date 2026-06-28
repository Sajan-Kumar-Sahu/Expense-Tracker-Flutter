import 'package:expense_tracker/core/utils/app_refresh.dart';
import 'package:expense_tracker/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_provider.dart';
import 'package:expense_tracker/features/transactions/data/models/UpdateTransactionRequest.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_request.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:expense_tracker/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class AddEditTransactionPage extends ConsumerStatefulWidget {
  final TransactionEntity? transaction;

  /// Pre-selects the transaction type when opening from quick actions.
  /// 1 = Income, 2 = Expense, 3 = Transfer. Ignored when editing.
  final int? initialTransactionType;

  const AddEditTransactionPage({
    super.key,
    this.transaction,
    this.initialTransactionType,
  });

  @override
  ConsumerState<AddEditTransactionPage> createState() =>
      _AddEditTransactionPageState();
}

class _AddEditTransactionPageState
    extends ConsumerState<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;
  late final TextEditingController _partyController;
  late final TextEditingController _notesController;

  bool _isLoading = false;

  int _transactionType = 2;

  String? _selectedAccountId;
  String? _selectedTransferAccountId;
  String? _selectedCategoryId;

  DateTime _selectedDate = DateTime.now();

  final Map<int, String> _transactionTypes = {
    1: 'Income',
    2: 'Expense',
    3: 'Transfer',
  };

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;

    _amountController = TextEditingController(
      text: transaction?.amount.toString() ?? '',
    );

    _partyController = TextEditingController(
      text: transaction?.party ?? '',
    );

    _notesController = TextEditingController(
      text: transaction?.notes ?? '',
    );

    if (transaction != null) {
      _transactionType = transaction.transactionType;
      _selectedAccountId = transaction.accountId;
      _selectedTransferAccountId = transaction.transferAccountId;
      _selectedCategoryId = transaction.categoryId.isEmpty ? null : transaction.categoryId;
      _selectedDate = transaction.transactionDate;
    } else if (widget.initialTransactionType != null) {
      _transactionType = widget.initialTransactionType!;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _partyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsState =
    ref.watch(accountsProvider);

    final categoriesState =
    ref.watch(categoriesProvider);

    final accounts = accountsState.accounts
        .where((a) => a.isActive)
        .toList();

    final categories = categoriesState.categories
        .where((c) =>
            c.isActive &&
            _transactionType != 3 &&
            c.categoryType == _transactionType)
        .toList();

    final isEditing =
        widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Transaction'
              : 'Add Transaction',
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// Transaction Type
              DropdownButtonFormField<int>(
                initialValue: _transactionType,
                decoration: const InputDecoration(
                  labelText: 'Transaction Type',
                ),
                items: _transactionTypes.entries
                    .map(
                      (e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _transactionType = value;
                    _selectedCategoryId = null;
                  });
                },
              ),

              SizedBox(height: 16.h),

              /// Account
              DropdownButtonFormField<String>(
                initialValue: _selectedAccountId,
                decoration: const InputDecoration(
                  labelText: 'Account',
                ),
                items: accounts
                    .map(
                      (account) => DropdownMenuItem(
                    value: account.id,
                    child: Text(account.name),
                  ),
                )
                    .toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select account';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _selectedAccountId = value;
                  });
                },
              ),

              SizedBox(height: 16.h),

              /// Transfer Account
              if (_transactionType == 3)
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue:
                      _selectedTransferAccountId,
                      decoration: const InputDecoration(
                        labelText: 'Transfer To',
                      ),
                      items: accounts
                          .map(
                            (account) =>
                            DropdownMenuItem(
                              value: account.id,
                              child:
                              Text(account.name),
                            ),
                      )
                          .toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Select transfer account';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedTransferAccountId =
                              value;
                        });
                      },
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),

              /// Category
              if (_transactionType != 3)
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue:
                      _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: categories
                          .map(
                            (category) =>
                            DropdownMenuItem(
                              value: category.id,
                              child:
                              Text(category.name),
                            ),
                      )
                          .toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select category';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId =
                              value;
                        });
                      },
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),

              /// Amount
              CustomTextField(
                controller: _amountController,
                labelText: 'Amount',
                keyboardType:
                TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter amount';
                  }

                  return null;
                },
              ),

              SizedBox(height: 16.h),

              /// Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Transaction Date',
                ),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing:
                const Icon(Icons.calendar_month),
                onTap: _pickDate,
              ),

              SizedBox(height: 16.h),

              /// Paid To / Received From
              if (_transactionType != 3)
                Column(
                  children: [
                    CustomTextField(
                      controller:
                      _partyController,
                      labelText: _transactionType == 1 ? 'Received From' : 'Paid To',
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),

              /// Notes
              CustomTextField(
                controller: _notesController,
                labelText: 'Notes',
              ),

              SizedBox(height: 40.h),

              CustomButton(
                text: isEditing
                    ? 'Save Changes'
                    : 'Create Transaction',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final isEditing =
        widget.transaction != null;

    bool success;

    if (isEditing) {
      success = await ref
          .read(transactionsProvider)
          .updateTransaction(
        UpdateTransactionRequest(
          id: widget.transaction!.id,

          accountId: _selectedAccountId!,

          transferAccountId:
          _transactionType == 3
              ? _selectedTransferAccountId
              : null,

          categoryId:
          _transactionType == 3
              ? null
              : _selectedCategoryId,

          transactionType:
          _transactionType,

          amount: double.parse(
            _amountController.text.trim(),
          ),

          transactionDate:
          _selectedDate,

          party:
          _transactionType == 3
              ? ''
              : _partyController.text.trim(),

          notes:
          _notesController.text.trim(),
        ),
      );
    } else {
      success = await ref
          .read(transactionsProvider)
          .createTransaction(
        TransactionRequest(
          accountId: _selectedAccountId!,

          transferAccountId:
          _transactionType == 3
              ? _selectedTransferAccountId
              : null,

          categoryId:
          _transactionType == 3
              ? null
              : _selectedCategoryId,

          transactionType:
          _transactionType,

          amount: double.parse(
            _amountController.text.trim(),
          ),

          transactionDate:
          _selectedDate,

          party:
          _transactionType == 3
              ? ''
              : _partyController.text.trim(),

          notes:
          _notesController.text.trim(),
        ),
      );
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      await refreshAll(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Transaction updated' : 'Transaction created'),
        ),
      );
      context.go(AppRouter.home);
    }
  }
}