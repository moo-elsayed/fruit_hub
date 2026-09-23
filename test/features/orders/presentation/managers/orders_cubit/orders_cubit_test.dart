import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/entities/order_item_entity.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/orders/domain/use_cases/stream_user_orders_use_case.dart';
import 'package:fruit_hub/features/orders/presentation/managers/orders_cubit/orders_cubit.dart';
import 'package:fruit_hub/features/orders/presentation/managers/orders_cubit/orders_state.dart';
import 'package:mocktail/mocktail.dart';

class MockStreamUserOrdersUseCase extends Mock
    implements StreamUserOrdersUseCase {}

void main() {
  late MockStreamUserOrdersUseCase mockStreamUserOrdersUseCase;
  late OrdersCubit sut;

  const tAddressEntity = AddressEntity(
    name: 'أحمد محمد',
    email: 'ahmed@example.com',
    phone: '01012345678',
    city: 'القاهرة',
    streetName: 'شارع التحرير',
    buildingNumber: '10',
    floorNumber: '3',
    apartmentNumber: '5',
  );

  const tOrderItemEntity = OrderItemEntity(
    name: 'تفاح أحمر',
    code: 'APPLE_01',
    imagePath: 'assets/images/red_apple.png',
    price: 25.0,
    quantity: 2,
  );

  final tOrderEntity1 = OrderEntity(
    docId: 'DOC_1',
    uId: 'user_123',
    orderId: 1001,
    totalPrice: 80.0,
    status: OrderStatus.pending,
    paymentOption: PaymentOptionEntity(
      title: AppStrings.cashOnDelivery,
      type: PaymentMethodType.cash,
      shippingCost: 30.0,
    ),
    shippingAddress: tAddressEntity,
    orderItems: const [tOrderItemEntity],
    date: '2026-09-01T10:00:00',
  );

  final tOrderEntity2 = OrderEntity(
    docId: 'DOC_2',
    uId: 'user_123',
    orderId: 1002,
    totalPrice: 150.0,
    status: OrderStatus.shipped,
    paymentOption: PaymentOptionEntity(
      title: AppStrings.payByPaypal,
      type: PaymentMethodType.paypal,
      shippingCost: 100.0,
    ),
    shippingAddress: tAddressEntity,
    orderItems: const [tOrderItemEntity],
    date: '2026-09-05T12:00:00',
  );

  final tServerFailure = ServerFailure(error: AppStrings.noInternetConnection);

  setUp(() {
    mockStreamUserOrdersUseCase = MockStreamUserOrdersUseCase();
    sut = OrdersCubit(mockStreamUserOrdersUseCase);
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be OrdersInitial', () {
    // Assert
    expect(sut.state, const OrdersInitial());
    expect(sut.currentOrders, isEmpty);
  });

  group('streamOrders', () {
    blocTest<OrdersCubit, OrdersState>(
      'should emit [OrdersLoading, OrdersSuccess] and update currentOrders when usecase emits NetworkSuccess',
      build: () {
        when(() => mockStreamUserOrdersUseCase())
            .thenAnswer((_) => Stream.value(NetworkSuccess([tOrderEntity1])));
        return sut;
      },
      act: (cubit) => cubit.streamOrders(),
      expect: () => [
        const OrdersLoading(),
        OrdersSuccess([tOrderEntity1]),
      ],
      verify: (_) {
        expect(sut.currentOrders, [tOrderEntity1]);
        verify(() => mockStreamUserOrdersUseCase()).called(1);
      },
    );

    blocTest<OrdersCubit, OrdersState>(
      'should emit [OrdersLoading, OrdersFailure] with error string when usecase emits NetworkFailure',
      build: () {
        when(() => mockStreamUserOrdersUseCase())
            .thenAnswer((_) => Stream.value(NetworkFailure(tServerFailure)));
        return sut;
      },
      act: (cubit) => cubit.streamOrders(),
      expect: () => [
        const OrdersLoading(),
        OrdersFailure(tServerFailure.error),
      ],
      verify: (_) {
        verify(() => mockStreamUserOrdersUseCase()).called(1);
      },
    );

    blocTest<OrdersCubit, OrdersState>(
      'should emit [OrdersLoading, OrdersFailure] when usecase stream emits error via onError',
      build: () {
        when(() => mockStreamUserOrdersUseCase()).thenAnswer(
          (_) => Stream.error(Exception('Firestore stream failure')),
        );
        return sut;
      },
      act: (cubit) => cubit.streamOrders(),
      expect: () => [
        const OrdersLoading(),
        isA<OrdersFailure>().having(
          (s) => s.message,
          'message',
          contains('Firestore stream failure'),
        ),
      ],
      verify: (_) {
        verify(() => mockStreamUserOrdersUseCase()).called(1);
      },
    );

    test('should emit multiple OrdersSuccess states and update currentOrders in real-time when usecase stream emits new lists', () async {
      // Arrange
      final streamController =
          StreamController<NetworkResponse<List<OrderEntity>>>();
      when(() => mockStreamUserOrdersUseCase())
          .thenAnswer((_) => streamController.stream);

      final states = <OrdersState>[];
      final subscription = sut.stream.listen(states.add);

      // Act
      sut.streamOrders();
      await pumpEventQueue();

      streamController.add(NetworkSuccess([tOrderEntity1]));
      await pumpEventQueue();

      streamController.add(NetworkSuccess([tOrderEntity1, tOrderEntity2]));
      await pumpEventQueue();

      // Assert
      expect(states, [
        const OrdersLoading(),
        OrdersSuccess([tOrderEntity1]),
        OrdersSuccess([tOrderEntity1, tOrderEntity2]),
      ]);
      expect(sut.currentOrders, [tOrderEntity1, tOrderEntity2]);

      await streamController.close();
      await subscription.cancel();
    });
  });
}
