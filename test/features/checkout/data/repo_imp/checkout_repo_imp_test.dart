import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/entities/order_item_entity.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/models/order_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/checkout/data/data_sources/remote/checkout_remote_data_source.dart';
import 'package:fruit_hub/features/checkout/data/models/payment_input_model.dart';
import 'package:fruit_hub/features/checkout/data/models/shipping_config_model.dart';
import 'package:fruit_hub/features/checkout/data/repo_imp/checkout_repo_imp.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_input_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutRemoteDataSource extends Mock
    implements CheckoutRemoteDataSource {}

class FakeOrderModel extends Fake implements OrderModel {}

class FakePaymentInputModel extends Fake implements PaymentInputModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeOrderModel());
    registerFallbackValue(FakePaymentInputModel());
  });

  late MockCheckoutRemoteDataSource mockCheckoutRemoteDataSource;
  late CheckoutRepoImp sut;

  const tFailure = ServerFailure(error: 'An unexpected error occurred');

  final tShippingConfigModel = ShippingConfigModel(
    shippingCost: 30.0,
    freeShippingThreshold: 200.0,
  );

  const tAddressEntity = AddressEntity(
    name: 'أحمد محمود',
    email: 'ahmed@example.com',
    phone: '01012345678',
    city: 'القاهرة',
    streetName: 'شارع التحرير',
    buildingNumber: '10',
    floorNumber: '3',
    apartmentNumber: '5',
    latitude: 30.0444,
    longitude: 31.2357,
  );

  const tOrderItemEntity = OrderItemEntity(
    name: 'تفاح أحمر',
    code: 'APPLE_01',
    imagePath: 'assets/images/red_apple.png',
    price: 25.0,
    quantity: 2,
  );

  const tPaymentOptionEntity = PaymentOptionEntity(
    type: PaymentMethodType.card,
    shippingCost: 30.0,
  );

  const tOrderEntity = OrderEntity(
    uId: 'user_123',
    orderId: 1001,
    totalPrice: 80.0,
    status: OrderStatus.pending,
    paymentOption: tPaymentOptionEntity,
    date: '2026-09-24T12:00:00',
    shippingAddress: tAddressEntity,
    orderItems: [tOrderItemEntity],
  );

  final tPaymentInputEntity = PaymentInputEntity(
    amount: 150.0,
    currency: 'usd',
    customerId: 'cus_123',
  );

  setUp(() {
    mockCheckoutRemoteDataSource = MockCheckoutRemoteDataSource();
    sut = CheckoutRepoImp(mockCheckoutRemoteDataSource);
  });

  group('fetchShippingConfig', () {
    test('should return NetworkSuccess with mapped ShippingConfigEntity when remote data source succeeds', () async {
      // Arrange
      when(() => mockCheckoutRemoteDataSource.fetchShippingConfig())
          .thenAnswer((_) async => NetworkSuccess(tShippingConfigModel));

      // Act
      final result = await sut.fetchShippingConfig();

      // Assert
      expect(result, isA<NetworkSuccess<ShippingConfigEntity>>());
      final data = (result as NetworkSuccess<ShippingConfigEntity>).data;
      expect(data, isNotNull);
      expect(data!.shippingCost, tShippingConfigModel.shippingCost);
      expect(
        data.freeShippingThreshold,
        tShippingConfigModel.freeShippingThreshold,
      );
      verify(() => mockCheckoutRemoteDataSource.fetchShippingConfig())
          .called(1);
      verifyNoMoreInteractions(mockCheckoutRemoteDataSource);
    });

    test('should return cached ShippingConfigEntity on subsequent calls without calling remote data source again', () async {
      // Arrange
      when(() => mockCheckoutRemoteDataSource.fetchShippingConfig())
          .thenAnswer((_) async => NetworkSuccess(tShippingConfigModel));

      // Act
      final firstResult = await sut.fetchShippingConfig();
      final secondResult = await sut.fetchShippingConfig();

      // Assert
      expect(firstResult, isA<NetworkSuccess<ShippingConfigEntity>>());
      expect(secondResult, isA<NetworkSuccess<ShippingConfigEntity>>());
      expect(
        (firstResult as NetworkSuccess<ShippingConfigEntity>).data,
        (secondResult as NetworkSuccess<ShippingConfigEntity>).data,
      );
      verify(() => mockCheckoutRemoteDataSource.fetchShippingConfig()).called(1);
      verifyNoMoreInteractions(mockCheckoutRemoteDataSource);
    });

    test(
      'should return NetworkFailure when remote data source fails',
      () async {
        // Arrange
        when(() => mockCheckoutRemoteDataSource.fetchShippingConfig())
            .thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut.fetchShippingConfig();

        // Assert
        expect(result, isA<NetworkFailure<ShippingConfigEntity>>());
        final failure =
            (result as NetworkFailure<ShippingConfigEntity>).failure;
        expect(failure.error, tFailure.error);
        verify(() => mockCheckoutRemoteDataSource.fetchShippingConfig())
            .called(1);
        verifyNoMoreInteractions(mockCheckoutRemoteDataSource);
      },
    );
  });

  group('addOrder', () {
    test('should return NetworkSuccess and pass properly mapped OrderModel when remote data source succeeds', () async {
      // Arrange
      when(() => mockCheckoutRemoteDataSource.addOrder(any()))
          .thenAnswer((_) async => const NetworkSuccess(null));

      // Act
      final result = await sut.addOrder(tOrderEntity);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      final captured = verify(
        () => mockCheckoutRemoteDataSource.addOrder(captureAny()),
      ).captured;
      expect(captured, hasLength(1));
      final passedModel = captured.first as OrderModel;
      expect(passedModel.uId, tOrderEntity.uId);
      expect(passedModel.orderId, tOrderEntity.orderId);
      expect(passedModel.totalPrice, tOrderEntity.totalPrice);
      expect(passedModel.status, tOrderEntity.status);
      expect(
        passedModel.paymentMethod,
        tOrderEntity.paymentOption.type.databaseValue,
      );
      expect(
        passedModel.shippingAddress.city,
        tOrderEntity.shippingAddress.city,
      );
      expect(
        passedModel.shippingAddress.streetName,
        tOrderEntity.shippingAddress.streetName,
      );
      expect(
        passedModel.orderItems.first.code,
        tOrderEntity.orderItems.first.code,
      );
      expect(
        passedModel.orderItems.first.price,
        tOrderEntity.orderItems.first.price,
      );
      expect(
        passedModel.orderItems.first.quantity,
        tOrderEntity.orderItems.first.quantity,
      );
      verifyNoMoreInteractions(mockCheckoutRemoteDataSource);
    });

    test(
      'should return NetworkFailure when remote data source fails',
      () async {
        // Arrange
        when(() => mockCheckoutRemoteDataSource.addOrder(any()))
            .thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut.addOrder(tOrderEntity);

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure.error, tFailure.error);
        verify(() => mockCheckoutRemoteDataSource.addOrder(any())).called(1);
        verifyNoMoreInteractions(mockCheckoutRemoteDataSource);
      },
    );
  });

  group('makePayment', () {
    test('should return NetworkSuccess and pass properly mapped PaymentInputModel when remote data source succeeds', () async {
      // Arrange
      when(() => mockCheckoutRemoteDataSource.makePayment(any()))
          .thenAnswer((_) async => const NetworkSuccess(null));

      // Act
      final result = await sut.makePayment(tPaymentInputEntity);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      final captured = verify(
        () => mockCheckoutRemoteDataSource.makePayment(captureAny()),
      ).captured;
      expect(captured, hasLength(1));
      final passedModel = captured.first as PaymentInputModel;
      expect(passedModel.amount, tPaymentInputEntity.amount);
      expect(passedModel.currency, tPaymentInputEntity.currency);
      expect(passedModel.customerId, tPaymentInputEntity.customerId);
      verifyNoMoreInteractions(mockCheckoutRemoteDataSource);
    });

    test(
      'should return NetworkFailure when remote data source fails',
      () async {
        // Arrange
        when(() => mockCheckoutRemoteDataSource.makePayment(any()))
            .thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut.makePayment(tPaymentInputEntity);

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure.error, tFailure.error);
        verify(() => mockCheckoutRemoteDataSource.makePayment(any())).called(1);
        verifyNoMoreInteractions(mockCheckoutRemoteDataSource);
      },
    );
  });
}
