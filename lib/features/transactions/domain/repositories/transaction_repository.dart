import 'package:expense_tracker/features/transactions/data/models/UpdateTransactionRequest.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_request.dart';

import '../../../../core/common/result.dart';
import '../entities/transaction_entity.dart';

/// Contract definition for managing Transactions.
abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions(
      String userId,
      );

  Future<TransactionEntity> createTransaction(
      TransactionRequest request,
      );

  Future<TransactionEntity> getTransactionById(
      String id,
      );

  Future<TransactionEntity> updateTransaction(
      UpdateTransactionRequest request,
      );

  Future<void> deleteTransaction(
      String id,
      );
}