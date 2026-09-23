import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/entities/order_item_entity.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/models/order_item_model.dart';
import 'package:fruit_hub/core/models/order_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/checkout/data/models/address_model.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/orders/data/data_sources/remote/orders_remote_data_source.dart';
import 'package:fruit_hub/features/orders/data/repo_imp/orders_repo_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockOrdersRemoteDataSource extends Mock
    implements OrdersRemoteDataSource {}

void main() {
  late MockOrdersRemoteDataSource mockOrdersRemoteDataSource;
  late OrdersRepoImp sut;

  final tAddressModel = AddressModel(
    name: 'أحمد محمد',
    email: 'ahmed@example.com',
    phone: '01012345678',
    city: 'القاهرة',
    streetName: 'شارع التحرير',
    buildingNumber: '10',
    floorNumber: '3',
    apartmentNumber: '5',
  );

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

  const tOrderItemModel = OrderItemModel(
    name: 'تفاح أحمر',
    code: 'APPLE_01',
    imagePath: 'assets/images/red_apple.png',
    price: 25.0,
    quantity: 2,
  );

  const tOrderItemEntity = OrderItemEntity(
    name: 'تفاح أحمر',
    code: 'APPLE_01',
    imagePath: 'assets/images/red_apple.png',
    price: 25.0,
    quantity: 2,
  );

  final tOrderModel1 = OrderModel(
    docId: 'DOC_1',
    uId: 'user_123',
    orderId: 1001,
    totalPrice: 80.0,
    status: OrderStatus.pending,
    paymentMethod: 'Cash',
    shippingAddress: tAddressModel,
    orderItems: const [tOrderItemModel],
    date: '2026-09-01T10:00:00',
  );

  final tOrderModel2 = OrderModel(
    docId: 'DOC_2',
    uId: 'user_123',
    orderId: 1002,
    totalPrice: 150.0,
    status: OrderStatus.shipped,
    paymentMethod: 'Paypal',
    shippingAddress: tAddressModel,
    orderItems: const [tOrderItemModel],
    date: '2026-09-05T12:00:00',
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

  setUp(() {
    mockOrdersRemoteDataSource = MockOrdersRemoteDataSource();
    sut = OrdersRepoImp(mockOrdersRemoteDataSource);
  });

  group('streamUserOrders', () {
    test('should emit NetworkSuccess with mapped entities when remoteDataSource emits list of OrderModels', () async {
      // Arrange
      when(() => mockOrdersRemoteDataSource.streamUserOrders())
          .thenAnswer((_) => Stream.value([tOrderModel1, tOrderModel2]));

      // Act
      final stream = sut.streamUserOrders();

      // Assert
      await expectLater(
        stream,
        emits(
          isA<NetworkSuccess<List<OrderEntity>>>().having(
            (res) => res.data,
            'data',
            [tOrderEntity1, tOrderEntity2],
          ),
        ),
      );
      verify(() => mockOrdersRemoteDataSource.streamUserOrders()).called(1);
      verifyNoMoreInteractions(mockOrdersRemoteDataSource);
    });

    test('should emit NetworkFailure with ServerFailure when remoteDataSource stream emits an error', () async {
      // Arrange
      when(() => mockOrdersRemoteDataSource.streamUserOrders()).thenAnswer(
        (_) => Stream.error(Exception('Firestore connection error')),
      );

      // Act
      final stream = sut.streamUserOrders();

      // Assert
      await expectLater(
        stream,
        emits(isA<NetworkFailure<List<OrderEntity>>>()),
      );
      verify(() => mockOrdersRemoteDataSource.streamUserOrders()).called(1);
      verifyNoMoreInteractions(mockOrdersRemoteDataSource);
    });

    test('should emit multiple NetworkSuccess states in real-time when stream emits updates', () async {
      // Arrange
      final streamController = StreamController<List<OrderModel>>();
      when(() => mockOrdersRemoteDataSource.streamUserOrders())
          .thenAnswer((_) => streamController.stream);

      // Act & Assert
      final expectation = expectLater(
        sut.streamUserOrders(),
        emitsInOrder([
          isA<NetworkSuccess<List<OrderEntity>>>().having(
            (res) => res.data,
            'data',
            [tOrderEntity1],
          ),
          isA<NetworkSuccess<List<OrderEntity>>>().having(
            (res) => res.data,
            'data',
            [tOrderEntity1, tOrderEntity2],
          ),
        ]),
      );

      streamController.add([tOrderModel1]);
      streamController.add([tOrderModel1, tOrderModel2]);

      await expectation;
      await streamController.close();
    });
  });

  group('streamOrderById', () {
    const tOrderId = '1001';

    test('should emit NetworkSuccess with mapped entity when remoteDataSource emits OrderModel', () async {
      // Arrange
      when(() => mockOrdersRemoteDataSource.streamOrderById(tOrderId))
          .thenAnswer((_) => Stream.value(tOrderModel1));

      // Act
      final stream = sut.streamOrderById(tOrderId);

      // Assert
      await expectLater(
        stream,
        emits(
          isA<NetworkSuccess<OrderEntity>>().having(
            (res) => res.data,
            'data',
            tOrderEntity1,
          ),
        ),
      );
      verify(() => mockOrdersRemoteDataSource.streamOrderById(tOrderId))
          .called(1);
      verifyNoMoreInteractions(mockOrdersRemoteDataSource);
    });

    test('should emit NetworkFailure with ServerFailure when remoteDataSource stream emits an error', () async {
      // Arrange
      when(() => mockOrdersRemoteDataSource.streamOrderById(tOrderId))
          .thenAnswer(
            (_) => Stream.error(BusinessException(AppStrings.notFoundError)),
          );

      // Act
      final stream = sut.streamOrderById(tOrderId);

      // Assert
      await expectLater(
        stream,
        emits(
          isA<NetworkFailure<OrderEntity>>().having(
            (res) => res.failure.error,
            'error',
            AppStrings.notFoundError,
          ),
        ),
      );
      verify(() => mockOrdersRemoteDataSource.streamOrderById(tOrderId))
          .called(1);
      verifyNoMoreInteractions(mockOrdersRemoteDataSource);
    });
  });

  group('cancelOrder', () {
    const tDocId = 'ORDER_DOC_ID';

    test('should call remoteDataSource.cancelOrder and return NetworkSuccess<void> when cancellation succeeds', () async {
      // Arrange
      when(() => mockOrdersRemoteDataSource.cancelOrder(tDocId))
          .thenAnswer((_) async {});

      // Act
      final result = await sut.cancelOrder(tDocId);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      verify(() => mockOrdersRemoteDataSource.cancelOrder(tDocId)).called(1);
      verifyNoMoreInteractions(mockOrdersRemoteDataSource);
    });

    test('should return NetworkFailure when remoteDataSource throws BusinessException', () async {
      // Arrange
      when(() => mockOrdersRemoteDataSource.cancelOrder(tDocId))
          .thenThrow(BusinessException(AppStrings.cannotCancelOrder));

      // Act
      final result = await sut.cancelOrder(tDocId);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.cannotCancelOrder);
      verify(() => mockOrdersRemoteDataSource.cancelOrder(tDocId)).called(1);
      verifyNoMoreInteractions(mockOrdersRemoteDataSource);
    });

    test('should return NetworkFailure with unexpected error when remoteDataSource throws general Exception', () async {
      // Arrange
      when(() => mockOrdersRemoteDataSource.cancelOrder(tDocId))
          .thenThrow(Exception('Unknown network failure'));

      // Act
      final result = await sut.cancelOrder(tDocId);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.unexpectedError);
      verify(() => mockOrdersRemoteDataSource.cancelOrder(tDocId)).called(1);
      verifyNoMoreInteractions(mockOrdersRemoteDataSource);
    });
  });
}
