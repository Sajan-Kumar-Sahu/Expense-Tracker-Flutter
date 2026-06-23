import 'package:expense_tracker/features/transactions/data/models/UpdateTransactionRequest.dart';
import 'package:expense_tracker/features/transactions/data/models/paged_response.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_request.dart';

import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<PagedResponse<TransactionEntity>> getTransactions({
    int page = 1,
    int pageSize = 20,
  });

  Future<TransactionEntity> createTransaction(TransactionRequest request);

  Future<TransactionEntity> getTransactionById(String id);

  Future<TransactionEntity> updateTransaction(UpdateTransactionRequest request);

  Future<void> deleteTransaction(String id);
}
