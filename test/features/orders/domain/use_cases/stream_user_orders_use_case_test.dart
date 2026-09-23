import 'dart:async';

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
import 'package:fruit_hub/features/orders/domain/repo/orders_repo.dart';
import 'package:fruit_hub/features/orders/domain/use_cases/stream_user_orders_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockOrdersRepo extends Mock implements OrdersRepo {}

void main() {
  late MockOrdersRepo mockOrdersRepo;
  late StreamUserOrdersUseCase sut;

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
    mockOrdersRepo = MockOrdersRepo();
    sut = StreamUserOrdersUseCase(mockOrdersRepo);
  });

  test('should forward stream from OrdersRepo.streamUserOrders and emit NetworkSuccess<List<OrderEntity>> when repo succeeds', () async {
    // Arrange
    when(() => mockOrdersRepo.streamUserOrders()).thenAnswer(
      (_) => Stream.value(NetworkSuccess([tOrderEntity1, tOrderEntity2])),
    );

    // Act
    final stream = sut();

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
    verify(() => mockOrdersRepo.streamUserOrders()).called(1);
    verifyNoMoreInteractions(mockOrdersRepo);
  });

  test('should forward stream from OrdersRepo.streamUserOrders and emit NetworkFailure<List<OrderEntity>> when repo emits failure', () async {
    // Arrange
    when(() => mockOrdersRepo.streamUserOrders())
        .thenAnswer((_) => Stream.value(NetworkFailure(tServerFailure)));

    // Act
    final stream = sut();

    // Assert
    await expectLater(
      stream,
      emits(
        isA<NetworkFailure<List<OrderEntity>>>().having(
          (res) => res.failure.error,
          'error',
          tServerFailure.error,
        ),
      ),
    );
    verify(() => mockOrdersRepo.streamUserOrders()).called(1);
    verifyNoMoreInteractions(mockOrdersRepo);
  });

  test('should emit real-time updates when OrdersRepo stream emits multiple responses', () async {
    // Arrange
    final controller = StreamController<NetworkResponse<List<OrderEntity>>>();
    when(() => mockOrdersRepo.streamUserOrders())
        .thenAnswer((_) => controller.stream);

    // Act & Assert
    final expectation = expectLater(
      sut(),
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

    controller.add(NetworkSuccess([tOrderEntity1]));
    controller.add(NetworkSuccess([tOrderEntity1, tOrderEntity2]));

    await expectation;
    await controller.close();
    verify(() => mockOrdersRepo.streamUserOrders()).called(1);
    verifyNoMoreInteractions(mockOrdersRepo);
  });
}
