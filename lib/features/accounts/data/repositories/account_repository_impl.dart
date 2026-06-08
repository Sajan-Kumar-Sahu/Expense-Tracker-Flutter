import 'package:expense_tracker/features/accounts/data/models/update_account_request.dart';

import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';
import '../models/account_request.dart';

class AccountRepositoryImpl
    implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl(
      this.remoteDataSource,
      );

  @override
  Future<AccountEntity> createAccount(
      AccountRequest request,
      ) async {
    return await remoteDataSource
        .createAccount(request);
  }

  @override
  Future<List<AccountEntity>> getAccounts()
  async {
    return await remoteDataSource
        .getAccounts();
  }

  @override
  Future<AccountEntity> getAccountById(
      String id,
      ) async {
    return await remoteDataSource
        .getAccountById(id);
  }

  @override
  Future<AccountEntity> updateAccount(
      UpdateAccountRequest request) async {
    return await remoteDataSource
        .updateAccount(request);
  }

  @override
  Future<bool> deleteAccount(
      String id) async {
    return await remoteDataSource
        .deleteAccount(id);
  }
}