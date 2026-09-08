import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';

import '../../../domain/use_cases/cancel_order_use_case.dart';
import '../../../domain/use_cases/stream_order_by_id_use_case.dart';
import 'track_order_state.dart';

class TrackOrderCubit extends Cubit<TrackOrderState> {
  TrackOrderCubit(
    this._streamOrderByIdUseCase,
    this._cancelOrderUseCase, {
    OrderEntity? initialOrder,
    String? orderId,
  }) : currentOrder = initialOrder,
       super(
         initialOrder != null
             ? TrackOrderSuccess(initialOrder)
             : const TrackOrderLoading(),
       ) {
    final id =
        orderId ??
        (initialOrder?.docId.isNotEmpty == true
            ? initialOrder!.docId
            : initialOrder != null && initialOrder.orderId != 0
            ? initialOrder.orderId.toString()
            : null);
    if (id != null && id.isNotEmpty) {
      streamOrder(id);
    }
  }

  final StreamOrderByIdUseCase _streamOrderByIdUseCase;
  final CancelOrderUseCase _cancelOrderUseCase;
  StreamSubscription? _orderSubscription;

  OrderEntity? currentOrder;

  void streamOrder(String orderId) {
    if (state is! TrackOrderSuccess) {
      emit(const TrackOrderLoading());
    }
    _orderSubscription?.cancel();
    _orderSubscription = _streamOrderByIdUseCase(orderId).listen(
      (response) {
        switch (response) {
          case NetworkSuccess<OrderEntity>(:final data):
            if (data != null) {
              currentOrder = data;
              emit(TrackOrderSuccess(data));
            }
          case NetworkFailure<OrderEntity>(:final error):
            if (currentOrder == null) {
              emit(TrackOrderFailure(error));
            }
        }
      },
      onError: (error) {
        if (currentOrder == null) {
          emit(TrackOrderFailure(error.toString()));
        }
      },
    );
  }

  Future<void> cancelCurrentOrder() async {
    final docId = currentOrder?.docId;
    if (docId == null || docId.isEmpty) return;

    emit(const TrackOrderCancelLoading());
    final result = await _cancelOrderUseCase(docId);
    switch (result) {
      case NetworkSuccess():
        emit(const TrackOrderCancelSuccess());
      case NetworkFailure(:final error):
        emit(TrackOrderCancelFailure(error));
        if (currentOrder != null) {
          emit(TrackOrderSuccess(currentOrder!));
        }
    }
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }
}
