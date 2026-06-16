import 'package:expense_tracker/features/transactions/data/models/UpdateTransactionRequest.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_request.dart';

import '../../../../core/common/result.dart';
import '../../../../core/errors/failures.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

import '../datasources/transaction_remote_data_source.dart';

class TransactionRepositoryImpl
    implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl(
      this.remoteDataSource,
      );

  @override
  Future<List<TransactionEntity>> getTransactions(
      String userId,
      ) async {
    final response =
    await remoteDataSource.getTransactions(userId);

    return response
        .map((e) => e.toEntity())
        .toList();
  }

  @override
  Future<TransactionEntity> createTransaction(
      TransactionRequest request,
      ) async {
    final response =
    await remoteDataSource.createTransaction(
      request,
    );

    return response.toEntity();
  }

  @override
  Future<TransactionEntity> getTransactionById(
      String id,
      ) async {
    final response =
    await remoteDataSource
        .getTransactionById(id);

    return response.toEntity();
  }

  @override
  Future<TransactionEntity> updateTransaction(
      UpdateTransactionRequest request,
      ) async {
    final response =
    await remoteDataSource
        .updateTransaction(request);

    return response.toEntity();
  }

  @override
  Future<void> deleteTransaction(
      String id,
      ) async {
    await remoteDataSource.deleteTransaction(id);
  }
}