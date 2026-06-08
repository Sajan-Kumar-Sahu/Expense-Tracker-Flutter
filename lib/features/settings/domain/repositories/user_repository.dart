import 'package:expense_tracker/features/settings/data/models/update_user_request.dart';

import '../../../../core/common/result.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Result<UserEntity>> getUserById(String id);
  Future<Result<UserEntity>> updateUser(
      String id,
      UpdateUserRequest request,
      );
}