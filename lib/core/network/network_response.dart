import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

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
  const NetworkFailure(this.failure);

  final Failure failure;

  String get error => failure.error;

  @override
  List<Object?> get props => [failure];
}
