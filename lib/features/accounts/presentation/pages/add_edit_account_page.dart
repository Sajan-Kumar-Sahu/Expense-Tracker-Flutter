import 'package:expense_tracker/features/accounts/data/models/account_request.dart';
import 'package:expense_tracker/features/accounts/data/models/update_account_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../routes/app_router.dart';
import '../../domain/entities/account_entity.dart';
import '../providers/accounts_provider.dart';

/// Screen supporting creation of a new Account or updating an existing one.
class AddEditAccountPage extends ConsumerStatefulWidget {
  final AccountEntity? account;

  const AddEditAccountPage({super.key, this.account});

  @override
  ConsumerState<AddEditAccountPage> createState() => _AddEditAccountPageState();
}

class _AddEditAccountPageState extends ConsumerState<AddEditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late int _selectedType;
  bool _isLoading = false;

  final Map<int, String> _accountTypes = {
    1: 'Bank',
    2: 'Cash',
    3: 'Credit Card',
    4: 'Wallet',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController = TextEditingController(text: widget.account?.openingBalance.toString() ?? '0.00');
    _selectedType = widget.account?.accountType ?? 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Account' : 'Add Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Account Name',
                hintText: 'e.g., Checking Account',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter account name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<int>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Account Type'),
                items: _accountTypes.entries.map(
                      (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                ).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: _balanceController,
                labelText: 'Initial Balance',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter balance';
                  }

                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }

                  return null;
                },
              ),
              SizedBox(height: 40.h),
              CustomButton(
                text: isEditing ? 'Save Changes' : 'Create Account',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final balance = double.parse(_balanceController.text.trim());
    final isEditing = widget.account != null;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    if (isEditing) {
      final success =
      await ref.read(accountsProvider).updateAccount(
        UpdateAccountRequest(
          id: widget.account!.id,
          userId: widget.account!.userId,
          name: name,
          description: widget.account!.description,
          isActive: widget.account!.isActive,
          accountType: _selectedType,
        ),
      );

      setState(() => _isLoading = false);

      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Account updated'),
          ),
        );

        router.go(AppRouter.home);
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to update account'),
          ),
        );
      }

      return;
    }

    final success =
    await ref.read(accountsProvider).createAccount(
      AccountRequest(
        userId: '94623bcb-fed5-47a0-a684-720dd84fcbe9',
        name: name,
        description: '',
        openingBalance: balance,
        accountType: _selectedType,
      ),
    );

    setState(() => _isLoading = false);

    if (success) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Account created'),
        ),
      );

      router.go(AppRouter.home);
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to create account'),
        ),
      );
    }
  }
}
