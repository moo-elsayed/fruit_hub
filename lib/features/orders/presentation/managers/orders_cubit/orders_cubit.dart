import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';

import '../../../domain/use_cases/cancel_order_use_case.dart';
import '../../../domain/use_cases/stream_user_orders_use_case.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._streamUserOrdersUseCase, this._cancelOrderUseCase)
    : super(const OrdersInitial());

  final StreamUserOrdersUseCase _streamUserOrdersUseCase;
  final CancelOrderUseCase _cancelOrderUseCase;
  StreamSubscription? _ordersSubscription;

  List<OrderEntity> currentOrders = [];

  void streamOrders() {
    emit(const OrdersLoading());
    _ordersSubscription?.cancel();
    _ordersSubscription = _streamUserOrdersUseCase().listen(
      (response) {
        switch (response) {
          case NetworkSuccess<List<OrderEntity>>(:final data):
            currentOrders = data ?? [];
            emit(OrdersSuccess(currentOrders));
          case NetworkFailure<List<OrderEntity>>(:final error):
            emit(OrdersFailure(error));
        }
      },
      onError: (error) {
        emit(OrdersFailure(error.toString()));
      },
    );
  }

  Future<void> cancelOrder(String docId) async {
    emit(OrderCancelLoading(docId));
    final result = await _cancelOrderUseCase(docId);
    switch (result) {
      case NetworkSuccess():
        emit(OrderCancelSuccess(docId));
      case NetworkFailure(:final error):
        emit(OrderCancelFailure(error));
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
