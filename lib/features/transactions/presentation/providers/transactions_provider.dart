import 'package:expense_tracker/features/transactions/data/models/UpdateTransactionRequest.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/dependency_injection/injection.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionsProvider extends ChangeNotifier {
  final TransactionRepository repository;

  TransactionsProvider(this.repository) {
    loadTransactions();
  }

  bool isLoading = false;

  List<TransactionEntity> transactions = [];

  TransactionEntity? selectedTransaction;

  static const _hardcodedUserId =
      '94623bcb-fed5-47a0-a684-720dd84fcbe9';

  Future<void> loadTransactions() async {
    try {
      isLoading = true;
      notifyListeners();

      transactions = await repository.getTransactions(
        _hardcodedUserId,
      );
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
  );
});