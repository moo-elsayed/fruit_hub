import 'package:equatable/equatable.dart';

sealed class NetworkResponse<T> {
  const NetworkResponse();
}

class NetworkSuccess<T> extends Equatable implements NetworkResponse<T> {
  const NetworkSuccess([this.data]);

  final T? data;

  @override
  List<Object?> get props => [data];
}

class NetworkFailure<T> extends Equatable implements NetworkResponse<T> {
  const NetworkFailure(this.exception);

  final Exception exception;

  @override
  List<Object?> get props => [exception];
}
