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
import 'package:fruit_hub/features/orders/domain/use_cases/stream_order_by_id_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockOrdersRepo extends Mock implements OrdersRepo {}

void main() {
  late MockOrdersRepo mockOrdersRepo;
  late StreamOrderByIdUseCase sut;

  const tOrderId = '1001';

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
    mockOrdersRepo = MockOrdersRepo();
    sut = StreamOrderByIdUseCase(mockOrdersRepo);
  });

  test('should forward stream from OrdersRepo.streamOrderById and emit NetworkSuccess<OrderEntity> when repo succeeds', () async {
    // Arrange
    when(() => mockOrdersRepo.streamOrderById(any()))
        .thenAnswer((_) => Stream.value(NetworkSuccess(tOrderEntity)));

    // Act
    final stream = sut(tOrderId);

    // Assert
    await expectLater(
      stream,
      emits(
        isA<NetworkSuccess<OrderEntity>>().having(
          (res) => res.data,
          'data',
          tOrderEntity,
        ),
      ),
    );
    verify(() => mockOrdersRepo.streamOrderById(tOrderId)).called(1);
    verifyNoMoreInteractions(mockOrdersRepo);
  });

  test('should forward stream from OrdersRepo.streamOrderById and emit NetworkFailure<OrderEntity> when repo emits failure', () async {
    // Arrange
    when(() => mockOrdersRepo.streamOrderById(any()))
        .thenAnswer((_) => Stream.value(NetworkFailure(tServerFailure)));

    // Act
    final stream = sut(tOrderId);

    // Assert
    await expectLater(
      stream,
      emits(
        isA<NetworkFailure<OrderEntity>>().having(
          (res) => res.failure.error,
          'error',
          tServerFailure.error,
        ),
      ),
    );
    verify(() => mockOrdersRepo.streamOrderById(tOrderId)).called(1);
    verifyNoMoreInteractions(mockOrdersRepo);
  });

  test('should emit real-time updates when OrdersRepo stream emits multiple responses', () async {
    // Arrange
    final controller = StreamController<NetworkResponse<OrderEntity>>();
    when(() => mockOrdersRepo.streamOrderById(any()))
        .thenAnswer((_) => controller.stream);

    // Act & Assert
    final expectation = expectLater(
      sut(tOrderId),
      emitsInOrder([
        isA<NetworkSuccess<OrderEntity>>().having(
          (res) => res.data,
          'data',
          tOrderEntity,
        ),
        isA<NetworkSuccess<OrderEntity>>().having(
          (res) => res.data,
          'data',
          tUpdatedOrderEntity,
        ),
      ]),
    );

    controller.add(NetworkSuccess(tOrderEntity));
    controller.add(NetworkSuccess(tUpdatedOrderEntity));

    await expectation;
    await controller.close();
    verify(() => mockOrdersRepo.streamOrderById(tOrderId)).called(1);
    verifyNoMoreInteractions(mockOrdersRepo);
  });
}
