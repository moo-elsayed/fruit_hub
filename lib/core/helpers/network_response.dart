sealed class NetworkResponse<T> {
  const NetworkResponse();
}

class NetworkSuccess<T> implements NetworkResponse<T> {
  NetworkSuccess([this.data]);

  final T? data;
}

class NetworkFailure<T> implements NetworkResponse<T> {
  NetworkFailure(this.exception);

  final Exception exception;
}
