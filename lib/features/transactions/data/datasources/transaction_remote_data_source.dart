import 'package:expense_tracker/core/constants/api_endpoints.dart';
import 'package:expense_tracker/core/network/api_client.dart';
import 'package:expense_tracker/features/transactions/data/models/UpdateTransactionRequest.dart';
import 'package:expense_tracker/features/transactions/data/models/paged_response.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_request.dart';

import '../models/transaction_response.dart';

abstract class TransactionRemoteDataSource {
  Future<PagedResponse<TransactionResponse>> getTransactions({
    int page = 1,
    int pageSize = 20,
  });

  Future<TransactionResponse> createTransaction(TransactionRequest request);

  Future<TransactionResponse> getTransactionById(String id);

  Future<TransactionResponse> updateTransaction(UpdateTransactionRequest request);

  Future<void> deleteTransaction(String id);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final ApiClient apiClient;

  TransactionRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PagedResponse<TransactionResponse>> getTransactions({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.transactions,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );

    return PagedResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
      TransactionResponse.fromJson,
    );
  }

  @override
  Future<TransactionResponse> createTransaction(TransactionRequest request) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.transactions,
      data: request.toJson(),
    );

    return TransactionResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<TransactionResponse> getTransactionById(String id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '${ApiEndpoints.transactions}/$id',
    );

    return TransactionResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<TransactionResponse> updateTransaction(UpdateTransactionRequest request) async {
    final response = await apiClient.patch<Map<String, dynamic>>(
      '${ApiEndpoints.transactions}/${request.id}',
      data: request.toJson(),
    );

    return TransactionResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await apiClient.delete<void>('${ApiEndpoints.transactions}/$id');
  }
}
