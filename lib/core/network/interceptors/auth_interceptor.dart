import 'package:dio/dio.dart';
import '../../storage/auth_storage.dart';
import '../api_constants.dart';

/// Attaches the JWT access token to every outgoing request.
class AuthInterceptor extends Interceptor {
  final AuthStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.authorization] =
          '${ApiConstants.bearer} $token';
    }

    options.headers[ApiConstants.accept] = ApiConstants.applicationJson;

    super.onRequest(options, handler);
  }
}
