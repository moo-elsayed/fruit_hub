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
import 'package:fruit_hub/features/orders/domain/use_cases/cancel_order_use_case.dart';
import 'package:fruit_hub/features/orders/domain/use_cases/stream_order_by_id_use_case.dart';
import 'package:fruit_hub/features/orders/presentation/managers/track_order_cubit/track_order_cubit.dart';
import 'package:fruit_hub/features/orders/presentation/managers/track_order_cubit/track_order_state.dart';
import 'package:mocktail/mocktail.dart';

class MockStreamOrderByIdUseCase extends Mock
    implements StreamOrderByIdUseCase {}

class MockCancelOrderUseCase extends Mock implements CancelOrderUseCase {}

void main() {
  late MockStreamOrderByIdUseCase mockStreamOrderByIdUseCase;
  late MockCancelOrderUseCase mockCancelOrderUseCase;

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

  final tOrderEntity = OrderEntity(
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

  final tUpdatedOrderEntity = OrderEntity(
    docId: 'DOC_1',
    uId: 'user_123',
    orderId: 1001,
    totalPrice: 80.0,
    status: OrderStatus.delivered,
    paymentOption: PaymentOptionEntity(
      title: AppStrings.cashOnDelivery,
      type: PaymentMethodType.cash,
      shippingCost: 30.0,
    ),
    shippingAddress: tAddressEntity,
    orderItems: const [tOrderItemEntity],
    date: '2026-09-01T10:00:00',
  );

  final tServerFailure = ServerFailure(error: AppStrings.notFoundError);

  setUp(() {
    mockStreamOrderByIdUseCase = MockStreamOrderByIdUseCase();
    mockCancelOrderUseCase = MockCancelOrderUseCase();
  });

  group('Constructor initialization', () {
    test('should have TrackOrderLoading initial state when initialOrder is null and orderId is null', () {
      // Arrange & Act
      final sut = TrackOrderCubit(
        mockStreamOrderByIdUseCase,
        mockCancelOrderUseCase,
      );

      // Assert
      expect(sut.state, const TrackOrderLoading());
      expect(sut.currentOrder, isNull);
      verifyZeroInteractions(mockStreamOrderByIdUseCase);

      sut.close();
    });

    test('should have TrackOrderSuccess initial state and start streaming when initialOrder is provided', () async {
      // Arrange
      when(() => mockStreamOrderByIdUseCase('DOC_1'))
          .thenAnswer((_) => Stream.value(NetworkSuccess(tOrderEntity)));

      // Act
      final sut = TrackOrderCubit(
        mockStreamOrderByIdUseCase,
        mockCancelOrderUseCase,
        initialOrder: tOrderEntity,
      );

      // Assert
      expect(sut.state, TrackOrderSuccess(tOrderEntity));
      expect(sut.currentOrder, tOrderEntity);
      verify(() => mockStreamOrderByIdUseCase('DOC_1')).called(1);

      await sut.close();
    });

    test('should start streaming with orderId when orderId is provided without initialOrder', () async {
      // Arrange
      when(() => mockStreamOrderByIdUseCase('1001'))
          .thenAnswer((_) => const Stream.empty());

      // Act
      final sut = TrackOrderCubit(
        mockStreamOrderByIdUseCase,
        mockCancelOrderUseCase,
        orderId: '1001',
      );

      // Assert
      expect(sut.state, const TrackOrderLoading());
      verify(() => mockStreamOrderByIdUseCase('1001')).called(1);

      await sut.close();
    });
  });

  group('streamOrder', () {
    const tOrderId = 'DOC_1';

    blocTest<TrackOrderCubit, TrackOrderState>(
      'should emit [TrackOrderSuccess] without TrackOrderLoading when initial state is already TrackOrderSuccess',
      setUp: () {
        when(
          () => mockStreamOrderByIdUseCase(tOrderId),
        ).thenAnswer((_) => Stream.value(NetworkSuccess(tUpdatedOrderEntity)));
      },
      build: () => TrackOrderCubit(
        mockStreamOrderByIdUseCase,
        mockCancelOrderUseCase,
        initialOrder: tOrderEntity,
      ),
      act: (cubit) => cubit.streamOrder(tOrderId),
      expect: () => [TrackOrderSuccess(tUpdatedOrderEntity)],
      verify: (cubit) {
        expect(cubit.currentOrder, tUpdatedOrderEntity);
      },
    );

    blocTest<TrackOrderCubit, TrackOrderState>(
      'should emit [TrackOrderLoading, TrackOrderSuccess] when starting from non-success state',
      build: () {
        when(() => mockStreamOrderByIdUseCase(tOrderId))
            .thenAnswer((_) => Stream.value(NetworkSuccess(tOrderEntity)));
        return TrackOrderCubit(
          mockStreamOrderByIdUseCase,
          mockCancelOrderUseCase,
        );
      },
      act: (cubit) => cubit.streamOrder(tOrderId),
      expect: () => [
        const TrackOrderLoading(),
        TrackOrderSuccess(tOrderEntity),
      ],
      verify: (cubit) {
        expect(cubit.currentOrder, tOrderEntity);
        verify(() => mockStreamOrderByIdUseCase(tOrderId)).called(1);
      },
    );

    blocTest<TrackOrderCubit, TrackOrderState>(
      'should emit [TrackOrderLoading, TrackOrderFailure] when usecase emits NetworkFailure and currentOrder is null',
      build: () {
        when(() => mockStreamOrderByIdUseCase(tOrderId))
            .thenAnswer((_) => Stream.value(NetworkFailure(tServerFailure)));
        return TrackOrderCubit(
          mockStreamOrderByIdUseCase,
          mockCancelOrderUseCase,
        );
      },
      act: (cubit) => cubit.streamOrder(tOrderId),
      expect: () => [
        const TrackOrderLoading(),
        TrackOrderFailure(tServerFailure.error),
      ],
    );

    blocTest<TrackOrderCubit, TrackOrderState>(
      'should NOT emit TrackOrderFailure when usecase emits NetworkFailure but currentOrder already exists',
      setUp: () {
        when(() => mockStreamOrderByIdUseCase(tOrderId))
            .thenAnswer((_) => const Stream.empty());
      },
      build: () => TrackOrderCubit(
        mockStreamOrderByIdUseCase,
        mockCancelOrderUseCase,
        initialOrder: tOrderEntity,
      ),
      act: (cubit) {
        when(() => mockStreamOrderByIdUseCase(tOrderId))
            .thenAnswer((_) => Stream.value(NetworkFailure(tServerFailure)));
        cubit.streamOrder(tOrderId);
      },
      expect: () => <TrackOrderState>[],
      verify: (cubit) {
        expect(cubit.currentOrder, tOrderEntity);
      },
    );

    blocTest<TrackOrderCubit, TrackOrderState>(
      'should emit TrackOrderFailure when stream emits error via onError and currentOrder is null',
      build: () {
        when(() => mockStreamOrderByIdUseCase(tOrderId))
            .thenAnswer((_) => Stream.error(Exception('Connection lost')));
        return TrackOrderCubit(
          mockStreamOrderByIdUseCase,
          mockCancelOrderUseCase,
        );
      },
      act: (cubit) => cubit.streamOrder(tOrderId),
      expect: () => [
        const TrackOrderLoading(),
        isA<TrackOrderFailure>().having(
          (s) => s.message,
          'message',
          contains('Connection lost'),
        ),
      ],
    );

    test(
      'should emit real-time updates when stream emits multiple order events',
      () async {
        // Arrange
        final streamController =
            StreamController<NetworkResponse<OrderEntity>>();
        when(() => mockStreamOrderByIdUseCase(tOrderId))
            .thenAnswer((_) => streamController.stream);

        final sut = TrackOrderCubit(
          mockStreamOrderByIdUseCase,
          mockCancelOrderUseCase,
        );

        final states = <TrackOrderState>[];
        final subscription = sut.stream.listen(states.add);

        // Act
        sut.streamOrder(tOrderId);
        await pumpEventQueue();

        streamController.add(NetworkSuccess(tOrderEntity));
        await pumpEventQueue();

        streamController.add(NetworkSuccess(tUpdatedOrderEntity));
        await pumpEventQueue();

        // Assert
        expect(states, [
          const TrackOrderLoading(),
          TrackOrderSuccess(tOrderEntity),
          TrackOrderSuccess(tUpdatedOrderEntity),
        ]);
        expect(sut.currentOrder, tUpdatedOrderEntity);

        await streamController.close();
        await subscription.cancel();
        await sut.close();
      },
    );
  });

  group('cancelCurrentOrder', () {
    test('should do nothing when currentOrder is null', () async {
      // Arrange
      final sut = TrackOrderCubit(
        mockStreamOrderByIdUseCase,
        mockCancelOrderUseCase,
      );

      // Act
      await sut.cancelCurrentOrder();

      // Assert
      expect(sut.state, const TrackOrderLoading());
      verifyZeroInteractions(mockCancelOrderUseCase);

      await sut.close();
    });

    blocTest<TrackOrderCubit, TrackOrderState>(
      'should emit [TrackOrderCancelLoading, TrackOrderCancelSuccess] when cancellation succeeds',
      setUp: () {
        when(() => mockStreamOrderByIdUseCase(any()))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockCancelOrderUseCase('DOC_1'))
            .thenAnswer((_) async => const NetworkSuccess(null));
      },
      build: () => TrackOrderCubit(
        mockStreamOrderByIdUseCase,
        mockCancelOrderUseCase,
        initialOrder: tOrderEntity,
      ),
      act: (cubit) => cubit.cancelCurrentOrder(),
      expect: () => [
        const TrackOrderCancelLoading(),
        const TrackOrderCancelSuccess(),
      ],
      verify: (_) {
        verify(() => mockCancelOrderUseCase('DOC_1')).called(1);
        verifyNoMoreInteractions(mockCancelOrderUseCase);
      },
    );

    blocTest<TrackOrderCubit, TrackOrderState>(
      'should emit [TrackOrderCancelLoading, TrackOrderCancelFailure, TrackOrderSuccess] when cancellation fails',
      setUp: () {
        when(() => mockStreamOrderByIdUseCase(any()))
            .thenAnswer((_) => const Stream.empty());
        when(() => mockCancelOrderUseCase('DOC_1'))
            .thenAnswer((_) async => NetworkFailure(tServerFailure));
      },
      build: () => TrackOrderCubit(
        mockStreamOrderByIdUseCase,
        mockCancelOrderUseCase,
        initialOrder: tOrderEntity,
      ),
      act: (cubit) => cubit.cancelCurrentOrder(),
      expect: () => [
        const TrackOrderCancelLoading(),
        TrackOrderCancelFailure(tServerFailure.error),
        TrackOrderSuccess(tOrderEntity),
      ],
      verify: (_) {
        verify(() => mockCancelOrderUseCase('DOC_1')).called(1);
        verifyNoMoreInteractions(mockCancelOrderUseCase);
      },
    );
  });
}
