import '../../../../core/common/result.dart' as res;
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final AuthStorage _storage;

  AuthRepositoryImpl(this._dataSource, this._storage);

  @override
  Future<res.Result<AuthEntity>> login(String email, String password) async {
    try {
      final model = await _dataSource.login(
        LoginRequest(email: email, password: password),
      );
      await _storage.saveAuth(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
        fullName: model.fullName,
        email: model.email,
      );
      return res.Success(model);
    } on ServerException catch (e) {
      return res.Failure(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return res.Failure(NetworkFailure(e.message));
    } catch (e) {
      return res.Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<res.Result<void>> logout() async {
    try {
      await _dataSource.logout();
    } catch (_) {
      // Best-effort — always clear local storage even if server call fails
    } finally {
      await _storage.clearAuth();
    }
    return const res.Success(null);
  }
}
