import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/auth_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/token_refresh_interceptor.dart';

/// Prepares and configures Dio with default settings from AppConfig.
class DioProvider {
  static Dio createDio([AuthStorage? authStorage]) {
    final storage = authStorage ?? AuthStorage();

    final options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
    );

    final dio = Dio(options);

    dio.interceptors.addAll([
      AuthInterceptor(storage),
      TokenRefreshInterceptor(storage, dio),
      LoggingInterceptor(),
    ]);

    return dio;
  }

  // Private constructor
  DioProvider._();
}
