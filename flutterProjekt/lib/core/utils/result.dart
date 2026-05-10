import '../errors/failures.dart';

/// A simple Either-like type for returning Failure or Success
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;

  T get value => (this as Success<T>).data;
  Failure get failure => (this as Error<T>).failure;

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    return switch (this) {
      Success<T>(data: final data) => onSuccess(data),
      Error<T>(failure: final failure) => onError(failure),
    };
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  @override
  final Failure failure;
  const Error(this.failure);
}
