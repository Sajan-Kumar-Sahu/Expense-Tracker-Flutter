import 'package:expense_tracker/core/constants/api_endpoints.dart';
import 'package:expense_tracker/core/network/api_client.dart';
import 'package:expense_tracker/features/transactions/data/models/UpdateTransactionRequest.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_request.dart';

import '../models/transaction_response.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionResponse>> getTransactions(String userId);

  Future<TransactionResponse> createTransaction(
      TransactionRequest request,
      );

  Future<TransactionResponse> getTransactionById(
      String id,
      );

  Future<TransactionResponse> updateTransaction(
      UpdateTransactionRequest request,
      );

  Future<void> deleteTransaction(
      String id,
      );
}

class TransactionRemoteDataSourceImpl
    implements TransactionRemoteDataSource {
  final ApiClient apiClient;

  TransactionRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<TransactionResponse>> getTransactions(
      String userId,
      ) async {
    final response = await apiClient.get(
      '${ApiEndpoints.transactions}/user/$userId',
    );

    return (response.data['data'] as List<dynamic>)
        .map((json) => TransactionResponse.fromJson(
      json as Map<String, dynamic>,
    ))
        .toList();
  }

  @override
  Future<TransactionResponse> createTransaction(
      TransactionRequest request,
      ) async {
    final response = await apiClient.post(
      ApiEndpoints.transactions,
      data: request.toJson(),
    );

    return TransactionResponse.fromJson(
        response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<TransactionResponse> getTransactionById(
      String id,
      ) async {
    final response = await apiClient.get(
      '${ApiEndpoints.transactions}/$id',
    );

    return TransactionResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<TransactionResponse> updateTransaction(
      UpdateTransactionRequest request,
      ) async {
    final response = await apiClient.patch(
      '${ApiEndpoints.transactions}/${request.id}',
      data: request.toJson(),
    );

    return TransactionResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteTransaction(
      String id,
      ) async {
    await apiClient.delete(
      '${ApiEndpoints.transactions}/$id',
    );
  }
}