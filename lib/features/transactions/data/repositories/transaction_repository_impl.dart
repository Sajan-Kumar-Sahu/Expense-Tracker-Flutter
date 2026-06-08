import '../../../../core/common/result.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

/// Skeleton implementation of the TransactionRepository contract.
class TransactionRepositoryImpl implements TransactionRepository {
  @override
  Future<Result<List<TransactionEntity>>> getTransactions() async {
    return const Success([]);
  }
}
