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

  static const int _pageSize = 20;

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;

  int _currentPage = 1;

  List<TransactionEntity> transactions = [];

  TransactionEntity? selectedTransaction;

  Future<void> loadTransactions() async {
    try {
      isLoading = true;
      _currentPage = 1;
      hasMore = true;
      notifyListeners();

      final paged = await repository.getTransactions(
        page: 1,
        pageSize: _pageSize,
      );

      transactions = paged.items;
      hasMore = paged.hasNextPage;
      _currentPage = 1;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;

    try {
      isLoadingMore = true;
      notifyListeners();

      final nextPage = _currentPage + 1;

      final paged = await repository.getTransactions(
        page: nextPage,
        pageSize: _pageSize,
      );

      transactions.addAll(paged.items);
      hasMore = paged.hasNextPage;
      _currentPage = nextPage;
    } catch (_) {
      // Keep existing transactions on error
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> createTransaction(TransactionRequest request) async {
    try {
      isLoading = true;
      notifyListeners();

      final transaction = await repository.createTransaction(request);
      transactions.insert(0, transaction);

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransactionById(String id) async {
    try {
      isLoading = true;
      notifyListeners();

      selectedTransaction = await repository.getTransactionById(id);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTransaction(UpdateTransactionRequest request) async {
    try {
      isLoading = true;
      notifyListeners();

      final updated = await repository.updateTransaction(request);

      final index = transactions.indexWhere((e) => e.id == updated.id);
      if (index != -1) {
        transactions[index] = updated;
      }

      if (selectedTransaction?.id == updated.id) {
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

  Future<bool> deleteTransaction(String id) async {
    try {
      isLoading = true;
      notifyListeners();

      await repository.deleteTransaction(id);

      transactions.removeWhere((e) => e.id == id);

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

  void reset() {
    transactions = [];
    selectedTransaction = null;
    isLoading = false;
    isLoadingMore = false;
    hasMore = true;
    _currentPage = 1;
    notifyListeners();
  }
}

final transactionsProvider = ChangeNotifierProvider<TransactionsProvider>((ref) {
  return TransactionsProvider(locator<TransactionRepository>());
});
