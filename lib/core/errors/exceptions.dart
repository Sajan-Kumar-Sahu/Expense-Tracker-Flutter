/// Exception thrown when a server-side error occurs, e.g., bad status code.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (Status Code: $statusCode)';
}

/// Exception thrown when connection timeouts or internet loss occurs.
class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Fallback exception for unexpected runtime errors at the network/data level.
class UnknownException implements Exception {
  final String message;

  const UnknownException(this.message);

  @override
  String toString() => 'UnknownException: $message';
}
