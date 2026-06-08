import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction_entity.dart';

/// Skeleton notifier for Transactions state management.
class TransactionsNotifier extends AsyncNotifier<List<TransactionEntity>> {
  @override
  FutureOr<List<TransactionEntity>> build() async {
    return [];
  }
}

/// App-wide provider for Transaction state.
final transactionsProvider = AsyncNotifierProvider<TransactionsNotifier, List<TransactionEntity>>(() {
  return TransactionsNotifier();
});
