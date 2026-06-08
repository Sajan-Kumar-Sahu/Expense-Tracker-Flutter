import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Prepares and configures Dio with default settings from AppConfig.
class DioProvider {
  static Dio createDio() {
    final options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
    );

    final dio = Dio(options);

    dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
    ]);

    return dio;
  }

  // Private constructor
  DioProvider._();
}
