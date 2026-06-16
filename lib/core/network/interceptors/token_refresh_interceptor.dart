import 'package:dio/dio.dart';
import '../../constants/api_endpoints.dart';
import '../../storage/auth_storage.dart';
import '../api_constants.dart';

/// Intercepts 401 responses, silently refreshes the access token using the
/// stored refresh token, and retries the original request once.
/// On refresh failure, clears auth storage (user will be logged out on next nav).
class TokenRefreshInterceptor extends Interceptor {
  final AuthStorage _storage;
  final Dio _dio;

  TokenRefreshInterceptor(this._storage, this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    if (response == null || response.statusCode != 401) {
      return handler.next(err);
    }

    // Don't retry refresh/login endpoints to avoid infinite loops
    final path = err.requestOptions.path;
    if (path.contains(ApiEndpoints.authRefreshToken) ||
        path.contains(ApiEndpoints.authLogin)) {
      return handler.next(err);
    }

    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _storage.clearAuth();
      return handler.next(err);
    }

    try {
      final refreshResponse = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authRefreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {ApiConstants.authorization: ''}),
      );

      final data = refreshResponse.data ?? <String, dynamic>{};
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String;
      final fullName = data['fullName'] as String? ?? '';
      final email = data['email'] as String? ?? '';

      await _storage.saveAuth(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        fullName: fullName,
        email: email,
      );

      // Retry the original request with the new token
      final retryOptions = err.requestOptions.copyWith(
        headers: {
          ...err.requestOptions.headers,
          ApiConstants.authorization: '${ApiConstants.bearer} $newAccessToken',
        },
      );
      final retryResponse = await _dio.fetch<dynamic>(retryOptions);
      return handler.resolve(retryResponse);
    } catch (_) {
      await _storage.clearAuth();
      return handler.next(err);
    }
  }
}
