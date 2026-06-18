import 'package:expense_tracker/core/storage/auth_storage.dart';
import 'package:expense_tracker/features/transactions/data/models/UpdateTransactionRequest.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/dependency_injection/injection.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionsProvider extends ChangeNotifier {
  final TransactionRepository repository;
  final AuthStorage _authStorage;

  TransactionsProvider(this.repository, this._authStorage) {
    loadTransactions();
  }

  bool isLoading = false;

  List<TransactionEntity> transactions = [];

  TransactionEntity? selectedTransaction;

  Future<String?> get _userId => _authStorage.getUserId();

  Future<void> loadTransactions() async {
    try {
      isLoading = true;
      notifyListeners();

      final userId = await _userId;
      if (userId == null) return;

      transactions = await repository.getTransactions(userId);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTransaction(
      TransactionRequest request,
      ) async {
    try {
      isLoading = true;
      notifyListeners();

      final transaction =
      await repository.createTransaction(
        request,
      );

      transactions.insert(
        0,
        transaction,
      );

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransactionById(
      String id,
      ) async {
    try {
      isLoading = true;
      notifyListeners();

      selectedTransaction =
      await repository
          .getTransactionById(id);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTransaction(
      UpdateTransactionRequest request,
      ) async {
    try {
      isLoading = true;
      notifyListeners();

      final updated =
      await repository.updateTransaction(
        request,
      );

      final index =
      transactions.indexWhere(
            (e) => e.id == updated.id,
      );

      if (index != -1) {
        transactions[index] = updated;
      }

      if (selectedTransaction?.id ==
          updated.id) {
        selectedTransaction = updated;
      }

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTransaction(
      String id,
      ) async {
    try {
      isLoading = true;
      notifyListeners();

      await repository.deleteTransaction(id);

      transactions.removeWhere(
            (e) => e.id == id,
      );

      if (selectedTransaction?.id == id) {
        selectedTransaction = null;
      }

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTransactions() async {
    await loadTransactions();
  }
}

final transactionsProvider =
ChangeNotifierProvider<TransactionsProvider>((ref) {
  return TransactionsProvider(
    locator<TransactionRepository>(),
    locator<AuthStorage>(),
  );
});