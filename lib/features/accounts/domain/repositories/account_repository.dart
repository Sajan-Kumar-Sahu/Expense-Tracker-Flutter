import 'package:expense_tracker/features/accounts/data/models/update_account_request.dart';

import '../entities/account_entity.dart';
import '../../data/models/account_request.dart';

abstract class AccountRepository {
  Future<AccountEntity> createAccount(
      AccountRequest request,
      );

  Future<List<AccountEntity>> getAccounts();

  Future<AccountEntity> getAccountById(
      String id,
      );
  Future<AccountEntity> updateAccount(
      UpdateAccountRequest request);

  Future<bool> deleteAccount(
      String id);
}