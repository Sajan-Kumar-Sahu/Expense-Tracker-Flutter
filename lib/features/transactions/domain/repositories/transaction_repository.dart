import '../../../../core/common/result.dart';
import '../entities/transaction_entity.dart';

/// Contract definition for managing Transactions.
abstract class TransactionRepository {
  Future<Result<List<TransactionEntity>>> getTransactions();
}
