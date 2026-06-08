import 'package:dio/dio.dart';
import '../api_constants.dart';

/// Interceptor to automatically attach JWT authorization headers to outgoing requests.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Future support: Retrieve actual token from Secure Storage/Preferences
    const String? token = null; 

    if (token != null) {
      options.headers[ApiConstants.authorization] = '${ApiConstants.bearer} $token';
    }

    options.headers[ApiConstants.accept] = ApiConstants.applicationJson;

    super.onRequest(options, handler);
  }
}
