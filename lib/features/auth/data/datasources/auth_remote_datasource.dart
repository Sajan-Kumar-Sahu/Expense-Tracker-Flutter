import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/login_request.dart';

class AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSource(this._client);

  Future<AuthResponseModel> login(LoginRequest request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.authLogin,
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  Future<void> logout() async {
    await _client.post<void>(ApiEndpoints.authLogout);
  }
}
