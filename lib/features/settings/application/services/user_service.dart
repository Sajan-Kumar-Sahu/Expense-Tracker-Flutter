import '../../data/models/update_user_request.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../../../core/common/result.dart';
import '../../domain/entities/user_entity.dart';

class UserService {
  final UserRepositoryImpl _repository;

  UserService(this._repository);

  Future<Result<UserEntity>> getUserById(
      String id,
      ) {
    return _repository.getUserById(id);
  }

  Future<Result<UserEntity>> updateUser({
    required String id,
    required String fullName,
    required String email,
  }) {
    return _repository.updateUser(
      id,
      UpdateUserRequest(
        fullName: fullName,
        email: email,
      ),
    );
  }
}