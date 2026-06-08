import '../errors/failures.dart' as err;

/// Sealed class for wrapping success values and failure errors.
/// Encourages compile-time checked error handling and avoids using exceptions
/// for control flow across architectural boundaries.
sealed class Result<T> {
  const Result();

  /// Maps the result into another type using callbacks for success and failure.
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(err.Failure failure) onFailure,
  ) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else if (this is Failure<T>) {
      return onFailure((this as Failure<T>).error);
    }
    throw AssertionError('Unexpected subclass of Result: $this');
  }
}

/// Representing a successful operation with data of type [T].
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);
}

/// Representing a failed operation containing a [Failure] object.
class Failure<T> extends Result<T> {
  final err.Failure error;

  const Failure(this.error);
}
