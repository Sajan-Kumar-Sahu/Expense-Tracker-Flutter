import 'package:expense_tracker/core/constants/api_endpoints.dart';
import 'package:expense_tracker/features/accounts/data/models/update_account_request.dart';

import '../models/account_request.dart';
import '../models/account_response.dart';
import '../../../../core/network/api_client.dart';

abstract class AccountRemoteDataSource {
  Future<AccountResponse> createAccount(
      AccountRequest request,
      );

  Future<List<AccountResponse>> getAccounts();

  Future<AccountResponse> getAccountById(
      String id,
      );

  Future<AccountResponse> updateAccount(
      UpdateAccountRequest request,
      );

  Future<bool> deleteAccount(
      String id,
      );
}

class AccountRemoteDataSourceImpl
    implements AccountRemoteDataSource {
  final ApiClient apiClient;

  AccountRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AccountResponse> createAccount(
      AccountRequest request) async {
    final response = await apiClient.post(
      ApiEndpoints.accounts,
      data: request.toJson(),
    );

    return AccountResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<AccountResponse>> getAccounts() async {
    final response = await apiClient.get(
      ApiEndpoints.accounts,
    );

    final List<dynamic> accounts = response.data['data'] as List<dynamic>;

    return accounts
        .map((e) => AccountResponse.fromJson(
      e as Map<String, dynamic>,
    ))
        .toList();
  }

  @override
  Future<AccountResponse> getAccountById(
      String id,
      ) async {
    final response = await apiClient.get(
      '${ApiEndpoints.accounts}/$id',
    );

    return AccountResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<AccountResponse> updateAccount(
      UpdateAccountRequest request) async {

    final response = await apiClient.patch(
      ApiEndpoints.accounts,
      data: request.toJson(),
    );

    return AccountResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<bool> deleteAccount(
      String id) async {

    await apiClient.delete(
      '${ApiEndpoints.accounts}/$id',
    );

    return true;
  }
}