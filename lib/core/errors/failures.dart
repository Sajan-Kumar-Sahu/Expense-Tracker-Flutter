import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures returned from repositories.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Representing database, server-side, or API specific failures.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again later.']);
}

/// Representing network availability and timeout failures.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Connection failed. Please check your internet network.']);
}

/// Fallback failure when an unexpected error happens.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
