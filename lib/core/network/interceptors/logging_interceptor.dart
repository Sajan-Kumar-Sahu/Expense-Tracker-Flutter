import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor to log Dio request and response payloads.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('--> [API REQUEST] ${options.method} ${options.uri}');
      debugPrint('Headers: ${options.headers}');
      if (options.data != null) {
        debugPrint('Body: ${options.data}');
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- [API RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
      debugPrint('Data: ${response.data}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- [API ERROR] ${err.message} (${err.requestOptions.uri})');
      if (err.response != null) {
        debugPrint('Status Code: ${err.response?.statusCode}');
        debugPrint('Response Body: ${err.response?.data}');
      }
    }
    super.onError(err, handler);
  }
}
