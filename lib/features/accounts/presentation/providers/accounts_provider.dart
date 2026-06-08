import 'package:expense_tracker/dependency_injection/injection.dart';
import 'package:expense_tracker/features/accounts/data/models/update_account_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/account_request.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';

class AccountsProvider extends ChangeNotifier {
  final AccountRepository repository;

  AccountsProvider(this.repository) {
    loadAccounts();
  }

  bool isLoading = false;

  List<AccountEntity> accounts = [];

  AccountEntity? selectedAccount;

  Future<void> loadAccounts() async {
    print("LOAD ACCOUNTS CALLED");

    try {
      isLoading = true;
      notifyListeners();

      accounts = await repository.getAccounts();

      print("Accounts count: ${accounts.length}");
    } catch (e) {
      print("ERROR: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAccountById(String id) async {
    try {
      isLoading = true;
      notifyListeners();

      selectedAccount =
      await repository.getAccountById(id);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAccount(
      AccountRequest request) async {
    try {
      isLoading = true;
      notifyListeners();

      final account =
      await repository.createAccount(request);

      accounts.add(account);

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAccount(
      UpdateAccountRequest request) async {

    try {
      isLoading = true;
      notifyListeners();

      final updated =
      await repository.updateAccount(
        request,
      );

      final index = accounts.indexWhere(
            (e) => e.id == updated.id,
      );

      if (index != -1) {
        accounts[index] = updated;
      }

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount(
      String id) async {

    try {
      isLoading = true;
      notifyListeners();

      await repository.deleteAccount(id);

      accounts.removeWhere(
            (e) => e.id == id,
      );

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

/// Riverpod Provider
final accountsProvider =
ChangeNotifierProvider<AccountsProvider>((ref) {
  return AccountsProvider(
    locator<AccountRepository>(),
  );
});