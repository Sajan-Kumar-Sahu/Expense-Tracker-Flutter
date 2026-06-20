import 'dart:async';

import 'package:dio/dio.dart';
import '../../auth/auth_event_bus.dart';
import '../../constants/api_endpoints.dart';
import '../../storage/auth_storage.dart';

/// Intercepts 401 responses, silently refreshes the access token using the
/// stored refresh token, and retries the original request once.
///
/// Uses a shared [Completer] as a mutex so that when multiple requests expire
/// at the same time (e.g., on cold start), only ONE refresh call is made.
/// All other queued 401s wait for that single refresh and reuse its token —
/// this prevents "concurrent refresh" from rotating the refresh token mid-flight
/// and invalidating requests that come right after.
class TokenRefreshInterceptor extends Interceptor {
  final AuthStorage _storage;
  final BaseOptions _baseOptions;

  // Shared across all instances via the static field — only one refresh at a time.
  static Completer<String?>? _refreshCompleter;

  TokenRefreshInterceptor(this._storage, this._baseOptions);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    if (response == null || response.statusCode != 401) {
      return handler.next(err);
    }

    // Don't attempt to refresh when the refresh/login endpoint itself fails.
    final path = err.requestOptions.path;
    if (path.contains(ApiEndpoints.authRefreshToken) ||
        path.contains(ApiEndpoints.authLogin)) {
      return handler.next(err);
    }

    // ── Mutex: if a refresh is already running, wait for its result ──────────
    if (_refreshCompleter != null) {
      final newToken = await _refreshCompleter!.future;
      if (newToken == null) {
        // The in-flight refresh already failed — pass the error along.
        return handler.next(err);
      }
      return _retry(err, newToken, handler);
    }

    // ── This request "wins" the lock — it performs the refresh ────────────────
    _refreshCompleter = Completer<String?>();

    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _complete(null);
      await _storage.clearAuth();
      notifySessionExpired();
      return handler.next(err);
    }

    try {
      // Use a bare Dio (no interceptors) so this request is NOT processed by
      // AuthInterceptor and does NOT carry the expired access token in the header.
      final refreshDio = Dio(BaseOptions(
        baseUrl: _baseOptions.baseUrl,
        connectTimeout: _baseOptions.connectTimeout,
        receiveTimeout: _baseOptions.receiveTimeout,
      ));

      final refreshResponse = await refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.authRefreshToken,
        data: {'refreshToken': refreshToken},
      );

      // Backend returns Result<AuthResponse>:
      // { isSuccess, message, data: { accessToken, refreshToken, fullName, email, expiresAt } }
      final outer = refreshResponse.data ?? <String, dynamic>{};
      final inner = (outer['data'] as Map<String, dynamic>?) ?? {};

      final newAccessToken = inner['accessToken'] as String;
      final newRefreshToken = inner['refreshToken'] as String;
      final fullName = inner['fullName'] as String? ?? '';
      final email = inner['email'] as String? ?? '';

      await _storage.saveAuth(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        fullName: fullName,
        email: email,
      );

      // Unblock all waiting 401s with the new token.
      _complete(newAccessToken);

      return _retry(err, newAccessToken, handler);
    } catch (_) {
      _complete(null);
      await _storage.clearAuth();
      notifySessionExpired();
      return handler.next(err);
    }
  }

  /// Resolve the completer and clear the static field so future refreshes can run.
  static void _complete(String? token) {
    _refreshCompleter?.complete(token);
    _refreshCompleter = null;
  }

  /// Retry the original request with a fresh access token, using a bare Dio
  /// so AuthInterceptor does not double-set the Authorization header.
  Future<void> _retry(
    DioException err,
    String newAccessToken,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final retryOptions = err.requestOptions.copyWith(
        headers: {
          ...err.requestOptions.headers,
          'Authorization': 'Bearer $newAccessToken',
        },
      );
      final retryDio = Dio(BaseOptions(
        baseUrl: _baseOptions.baseUrl,
        connectTimeout: _baseOptions.connectTimeout,
        receiveTimeout: _baseOptions.receiveTimeout,
      ));
      final retryResponse = await retryDio.fetch<dynamic>(retryOptions);
      return handler.resolve(retryResponse);
    } on DioException catch (retryErr) {
      // Retry failed for a non-auth reason — pass the original error through,
      // not the retry error, so callers see the right context.
      return handler.next(retryErr);
    }
  }
}
