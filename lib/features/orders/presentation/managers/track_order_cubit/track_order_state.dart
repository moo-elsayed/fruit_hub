import 'package:equatable/equatable.dart';

import 'package:fruit_hub/core/entities/order_entity.dart';

abstract class TrackOrderState extends Equatable {
  const TrackOrderState();

  @override
  List<Object?> get props => [];
}

class TrackOrderInitial extends TrackOrderState {
  const TrackOrderInitial();
}

class TrackOrderLoading extends TrackOrderState {
  const TrackOrderLoading();
}

class TrackOrderSuccess extends TrackOrderState {
  const TrackOrderSuccess(this.order);

  final OrderEntity order;

  @override
  List<Object?> get props => [order];
}

class TrackOrderFailure extends TrackOrderState {
  const TrackOrderFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class TrackOrderCancelLoading extends TrackOrderState {
  const TrackOrderCancelLoading();
}

class TrackOrderCancelSuccess extends TrackOrderState {
  const TrackOrderCancelSuccess();
}

class TrackOrderCancelFailure extends TrackOrderState {
  const TrackOrderCancelFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
