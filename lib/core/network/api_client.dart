import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

/// Generic client class that wraps Dio calls and standardizes error responses
/// by throwing specific NetworkException, ServerException, or UnknownException types.
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<Response<T>> patch<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Exception _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException('Connection timed out. Please check your network.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String message = 'Server returned an error status.';
        if (data is Map && data.containsKey('message')) {
          message = data['message'].toString();
        } else if (error.response?.statusMessage != null) {
          message = error.response!.statusMessage!;
        }
        return ServerException(message: message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return const UnknownException('Request was cancelled.');
      default:
        return UnknownException(error.message ?? 'An unexpected network error occurred.');
    }
  }
}
