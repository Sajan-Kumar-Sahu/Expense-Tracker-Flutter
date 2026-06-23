import '../../../../core/common/result.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Result<AuthEntity>> login(String mobileNumber, String password);
  Future<Result<void>> logout();
}
