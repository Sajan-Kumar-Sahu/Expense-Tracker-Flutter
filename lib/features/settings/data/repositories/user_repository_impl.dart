import 'package:expense_tracker/features/settings/data/models/update_user_request.dart';

import '../../../../core/common/result.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart' as err;
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<UserEntity>> getUserById(String id) async {
    try {
      final user = await _remoteDataSource.getUserById(id);

      return Success(user);
    } on ServerException catch (e) {
      return Failure(err.ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Failure(err.NetworkFailure(e.message));
    } catch (e) {
      return Failure(err.UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> updateUser(
      String id,
      UpdateUserRequest request,
      ) async {
    try {
      final user =
      await _remoteDataSource.updateUser(
        id,
        request,
      );

      return Success(user);
    } on ServerException catch (e) {
      return Failure(err.ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Failure(err.NetworkFailure(e.message));
    } catch (e) {
      return Failure(err.UnknownFailure(e.toString()));
    }
  }
}