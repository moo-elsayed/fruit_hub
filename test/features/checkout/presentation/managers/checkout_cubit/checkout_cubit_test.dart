import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/checkout/data/models/address_model.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_input_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/add_order_use_case.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/fetch_shipping_config_use_case.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/make_payment_use_case.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAppPreferencesService extends Mock implements AppPreferencesService {}

class MockFetchShippingConfigUseCase extends Mock
    implements FetchShippingConfigUseCase {}

class MockAddOrderUseCase extends Mock implements AddOrderUseCase {}

class MockMakePaymentUseCase extends Mock implements MakePaymentUseCase {}

class FakeOrderEntity extends Fake implements OrderEntity {}

class FakePaymentInputEntity extends Fake implements PaymentInputEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeOrderEntity());
    registerFallbackValue(FakePaymentInputEntity());
  });

  late MockAppPreferencesService mockAppPreferencesService;
  late MockFetchShippingConfigUseCase mockFetchShippingConfigUseCase;
  late MockAddOrderUseCase mockAddOrderUseCase;
  late MockMakePaymentUseCase mockMakePaymentUseCase;
  late CheckoutCubit sut;

  const tAddress = AddressEntity(
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

  const tFruit1 = FruitEntity(
    code: 'APPLE_01',
    name: 'تفاح',
    description: 'تفاح طازج',
    price: 25.0,
    imagePath: 'apple.png',
  );

  const tFruit2 = FruitEntity(
    code: 'BANANA_02',
    name: 'موز',
    description: 'موز طازج',
    price: 15.0,
    imagePath: 'banana.png',
  );

  const tCartItem1 = CartItemEntity(fruitEntity: tFruit1, quantity: 2); // 50.0
  const tCartItem2 = CartItemEntity(fruitEntity: tFruit2, quantity: 3); // 45.0
  final tProducts = [tCartItem1, tCartItem2]; // Subtotal: 95.0

  setUp(() {
    mockAppPreferencesService = MockAppPreferencesService();
    mockFetchShippingConfigUseCase = MockFetchShippingConfigUseCase();
    mockAddOrderUseCase = MockAddOrderUseCase();
    mockMakePaymentUseCase = MockMakePaymentUseCase();

    when(() => mockAppPreferencesService.getUser()).thenReturn(null);
    when(() => mockAppPreferencesService.getAddress()).thenReturn('');

    sut = CheckoutCubit(
      mockAppPreferencesService,
      mockFetchShippingConfigUseCase,
      mockAddOrderUseCase,
      mockMakePaymentUseCase,
    );
  });

  tearDown(() {
    sut.close();
  });

  group('initial state and properties', () {
    test('should have CheckoutInitial as initial state and default values', () {
      // Assert
      expect(sut.state, isA<CheckoutInitial>());
      expect(sut.products, isEmpty);
      expect(sut.address, isNull);
      expect(sut.saveAddress, isTrue);
      expect(sut.paymentOption.type, PaymentMethodType.paypal);
      expect(sut.shippingConfig.shippingCost, 0.0);
      expect(sut.orderId, greaterThanOrEqualTo(100000));
      expect(sut.orderId, lessThan(1000000));
      expect(sut.subtotal, 0.0);
    });
  });

  group('addOrder', () {
    blocTest<CheckoutCubit, CheckoutState>(
      'should emit [AddOrderLoading, AddOrderSuccess] when AddOrderUseCase returns NetworkSuccess',
      build: () {
        when(() => mockAddOrderUseCase(any()))
            .thenAnswer((_) async => const NetworkSuccess(null));
        return sut;
      },
      act: (cubit) => cubit.addOrder(),
      expect: () => [isA<AddOrderLoading>(), isA<AddOrderSuccess>()],
      verify: (cubit) {
        verify(() => mockAddOrderUseCase(any())).called(1);
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'should emit [AddOrderLoading, AddOrderFailure] when AddOrderUseCase returns NetworkFailure',
      build: () {
        when(() => mockAddOrderUseCase(any())).thenAnswer(
          (_) async => const NetworkFailure(
            ServerFailure(error: 'Failed to add order to database'),
          ),
        );
        return sut;
      },
      act: (cubit) => cubit.addOrder(),
      expect: () => [
        isA<AddOrderLoading>(),
        isA<AddOrderFailure>().having(
          (state) => state.errorMessage,
          'errorMessage',
          'Failed to add order to database',
        ),
      ],
      verify: (cubit) {
        verify(() => mockAddOrderUseCase(any())).called(1);
      },
    );
  });

  group('makePayment', () {
    blocTest<CheckoutCubit, CheckoutState>(
      'should emit [MakePaymentLoading, AddOrderLoading, AddOrderSuccess] when makePayment and addOrder both succeed',
      build: () {
        sut.setProducts(tProducts);
        sut.setPaymentOption(
          const PaymentOptionEntity(
            type: PaymentMethodType.card,
            shippingCost: 30.0,
          ),
        );

        when(() => mockMakePaymentUseCase(any()))
            .thenAnswer((_) async => const NetworkSuccess(null));

        when(() => mockAddOrderUseCase(any()))
            .thenAnswer((_) async => const NetworkSuccess(null));

        return sut;
      },
      act: (cubit) => cubit.makePayment(),
      expect: () => [
        isA<MakePaymentLoading>(),
        isA<AddOrderLoading>(),
        isA<AddOrderSuccess>(),
      ],
      verify: (cubit) {
        final captured = verify(() => mockMakePaymentUseCase(captureAny()))
            .captured;
        expect(captured, hasLength(1));
        final passedInput = captured.first as PaymentInputEntity;
        expect(passedInput.amount, 95.0 + 30.0);
        expect(passedInput.currency, 'usd');
        verify(() => mockAddOrderUseCase(any())).called(1);
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'should emit [MakePaymentLoading, MakePaymentFailure] and NOT call addOrder when makePayment fails',
      build: () {
        when(() => mockMakePaymentUseCase(any())).thenAnswer(
          (_) async =>
              const NetworkFailure(ServerFailure(error: 'Card declined')),
        );
        return sut;
      },
      act: (cubit) => cubit.makePayment(),
      expect: () => [
        isA<MakePaymentLoading>(),
        isA<MakePaymentFailure>().having(
          (state) => state.errorMessage,
          'errorMessage',
          'Card declined',
        ),
      ],
      verify: (cubit) {
        verify(() => mockMakePaymentUseCase(any())).called(1);
        verifyNever(() => mockAddOrderUseCase(any()));
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'should emit [MakePaymentLoading, AddOrderLoading, AddOrderFailure] when makePayment succeeds but addOrder fails',
      build: () {
        when(() => mockMakePaymentUseCase(any()))
            .thenAnswer((_) async => const NetworkSuccess(null));

        when(() => mockAddOrderUseCase(any())).thenAnswer(
          (_) async =>
              const NetworkFailure(ServerFailure(error: 'Database error')),
        );
        return sut;
      },
      act: (cubit) => cubit.makePayment(),
      expect: () => [
        isA<MakePaymentLoading>(),
        isA<AddOrderLoading>(),
        isA<AddOrderFailure>().having(
          (state) => state.errorMessage,
          'errorMessage',
          'Database error',
        ),
      ],
    );
  });

  group('fetchShippingConfig', () {
    test('should update shippingConfig and paymentOption when FetchShippingConfigUseCase returns NetworkSuccess', () async {
      // Arrange
      sut.setProducts(tProducts);
      sut.setPaymentOption(
        const PaymentOptionEntity(
          type: PaymentMethodType.cash,
          shippingCost: 0.0,
        ),
      );

      const tShippingConfig = ShippingConfigEntity(
        shippingCost: 35.0,
        freeShippingThreshold: 200.0,
      );

      when(() => mockFetchShippingConfigUseCase())
          .thenAnswer((_) async => const NetworkSuccess(tShippingConfig));

      // Act
      await sut.fetchShippingConfig();

      // Assert
      expect(sut.shippingConfig, tShippingConfig);
      expect(sut.paymentOption.type, PaymentMethodType.cash);
      expect(sut.paymentOption.shippingCost, 35.0);
      verify(() => mockFetchShippingConfigUseCase()).called(1);
    });

    test('should reset shippingConfig to default when FetchShippingConfigUseCase returns NetworkFailure', () async {
      // Arrange
      when(() => mockFetchShippingConfigUseCase()).thenAnswer(
        (_) async => const NetworkFailure(
          ServerFailure(error: 'Failed to fetch shipping config'),
        ),
      );

      // Act
      await sut.fetchShippingConfig();

      // Assert
      expect(sut.shippingConfig.shippingCost, 0.0);
      expect(sut.shippingConfig.freeShippingThreshold, isNull);
      verify(() => mockFetchShippingConfigUseCase()).called(1);
    });
  });

  group('setProducts and subtotal', () {
    test('should set products and calculate subtotal correctly', () {
      // Act
      sut.setProducts(tProducts);

      // Assert
      expect(sut.products, tProducts);
      expect(sut.subtotal, 95.0);
    });
  });

  group('setAddress and local storage saving', () {
    test(
      'should set address and save to local storage when saveAddress is true',
      () {
        // Arrange
        when(() => mockAppPreferencesService.saveAddress(any()))
            .thenAnswer((_) async {});

        // Act
        sut.setSaveAddress(true);
        sut.setAddress(tAddress);

        // Assert
        expect(sut.address, tAddress);
        final expectedJson = AddressModel.fromEntity(tAddress).toJson();
        verify(() => mockAppPreferencesService.saveAddress(expectedJson))
            .called(1);
      },
    );

    test('should set address and NOT save to local storage when saveAddress is false', () {
      // Act
      sut.setSaveAddress(false);
      sut.setAddress(tAddress);

      // Assert
      expect(sut.address, tAddress);
      verifyNever(() => mockAppPreferencesService.saveAddress(any()));
    });
  });

  group('getAddressFromLocalStorage', () {
    test(
      'should decode and set address when valid JSON exists in preferences',
      () {
        // Arrange
        final addressJson = jsonEncode(
          AddressModel.fromEntity(tAddress).toJson(),
        );
        when(() => mockAppPreferencesService.getAddress())
            .thenReturn(addressJson);

        // Act
        sut.getAddressFromLocalStorage();

        // Assert
        expect(sut.address, isNotNull);
        expect(sut.address!.city, tAddress.city);
        expect(sut.address!.streetName, tAddress.streetName);
        expect(sut.address!.phone, tAddress.phone);
      },
    );

    test('should do nothing when address string is empty in preferences', () {
      // Arrange
      when(() => mockAppPreferencesService.getAddress()).thenReturn('');

      // Act
      sut.getAddressFromLocalStorage();

      // Assert
      expect(sut.address, isNull);
    });

    test('should catch error and keep address null when JSON is malformed', () {
      // Arrange
      when(() => mockAppPreferencesService.getAddress())
          .thenReturn('malformed_json{{{');

      // Act
      sut.getAddressFromLocalStorage();

      // Assert
      expect(sut.address, isNull);
    });
  });

  group('setPaymentOption', () {
    test('should update paymentOption', () {
      // Arrange
      const tOption = PaymentOptionEntity(
        type: PaymentMethodType.paypal,
        shippingCost: 15.0,
      );

      // Act
      sut.setPaymentOption(tOption);

      // Assert
      expect(sut.paymentOption, tOption);
    });
  });

  group('orderEntity getter', () {
    test('should construct OrderEntity with authenticated user uid and current values', () {
      // Arrange
      const tUser = UserEntity(uid: 'user_xyz_789', name: 'أحمد');
      when(() => mockAppPreferencesService.getUser()).thenReturn(tUser);

      sut.setProducts(tProducts);
      sut.setSaveAddress(false);
      sut.setAddress(tAddress);
      sut.setPaymentOption(
        const PaymentOptionEntity(
          type: PaymentMethodType.card,
          shippingCost: 20.0,
        ),
      );

      // Act
      final order = sut.orderEntity;

      // Assert
      expect(order.uId, 'user_xyz_789');
      expect(order.orderId, sut.orderId);
      expect(order.shippingAddress, tAddress);
      expect(order.paymentOption.type, PaymentMethodType.card);
      expect(order.cartItems, tProducts);
      expect(order.orderItems, hasLength(2));
      expect(order.totalPrice, 95.0 + 20.0);
    });

    test('should fallback to empty string uid when user is null', () {
      // Arrange
      when(() => mockAppPreferencesService.getUser()).thenReturn(null);

      // Act
      final order = sut.orderEntity;

      // Assert
      expect(order.uId, '');
    });
  });
}
