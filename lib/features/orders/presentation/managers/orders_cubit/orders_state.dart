import 'package:equatable/equatable.dart';

import 'package:fruit_hub/core/entities/order_entity.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersSuccess extends OrdersState {
  const OrdersSuccess(this.orders);

  final List<OrderEntity> orders;

  @override
  List<Object?> get props => [orders];
}

class OrdersFailure extends OrdersState {
  const OrdersFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class OrderCancelLoading extends OrdersState {
  const OrderCancelLoading(this.docId);

  final String docId;

  @override
  List<Object?> get props => [docId];
}

class OrderCancelSuccess extends OrdersState {
  const OrderCancelSuccess(this.docId);

  final String docId;

  @override
  List<Object?> get props => [docId];
}

class OrderCancelFailure extends OrdersState {
  const OrderCancelFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
