import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/order_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/add_order_use_case.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/fetch_shipping_config_use_case.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorageService extends Mock implements AppPreferencesManager {}

class MockFetchShippingConfigUseCase extends Mock
    implements FetchShippingConfigUseCase {}

class MockAddOrderUseCase extends Mock implements AddOrderUseCase {}

class FakeOrderEntity extends Fake implements OrderEntity {}

void main() {
  late CheckoutCubit sut;
  late MockLocalStorageService mockLocalStorageService;
  late MockFetchShippingConfigUseCase mockFetchShippingConfigUseCase;
  late MockAddOrderUseCase mockAddOrderUseCase;

  final tAddress = const AddressEntity(
    name: 'Ahmed',
    email: 'test@test.com',
    phone: '010',
    city: 'Cairo',
    streetName: 'St',
    buildingNumber: '1',
    floorNumber: '1',
    apartmentNumber: '1',
  );

  final tAddressMap = {
    'name': 'Ahmed',
    'email': 'test@test.com',
    'phone': '010',
    'city': 'Cairo',
    'street': 'St',
    'building_number': '1',
    'floor_number': '1',
    'apartment_number': '1',
  };

  final tProducts = [
    const CartItemEntity(
      fruitEntity: FruitEntity(
        price: 100,
        name: 'Apple',
        code: '1',
        description: '',
        imagePath: '',
      ),
      quantity: 2,
    ), // Total: 200
    const CartItemEntity(
      fruitEntity: FruitEntity(
        price: 50,
        name: 'Banana',
        code: '2',
        description: '',
        imagePath: '',
      ),
      quantity: 1,
    ), // Total: 50
  ];

  final tPaymentOption = const PaymentOptionEntity(
    option: 'Cash',
    shippingCost: 40,
  );
  final tShippingConfig = const ShippingConfigEntity(shippingCost: 50.0);

  setUpAll(() {
    registerFallbackValue(FakeOrderEntity());
  });

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    mockFetchShippingConfigUseCase = MockFetchShippingConfigUseCase();
    mockAddOrderUseCase = MockAddOrderUseCase();
    sut = CheckoutCubit(
      mockLocalStorageService,
      mockFetchShippingConfigUseCase,
      mockAddOrderUseCase,
    );
  });

  tearDown(() {
    sut.close();
  });

  group('CheckoutCubit', () {
    test('initial state should be CheckoutInitial', () {
      expect(sut.state, isA<CheckoutInitial>());
    });

    group('fetchShippingConfig', () {
      test(
        'should update shippingConfig variable when fetch is successful',
        () async {
          // Arrange
          when(
            () => mockFetchShippingConfigUseCase(),
          ).thenAnswer((_) async => NetworkSuccess(tShippingConfig));
          // Act
          await sut.fetchShippingConfig();
          // Assert
          expect(sut.shippingConfig, tShippingConfig);
          verify(() => mockFetchShippingConfigUseCase()).called(1);
          verifyNoMoreInteractions(mockFetchShippingConfigUseCase);
        },
      );

      test(
        'should not update shippingConfig variable when fetch fails',
        () async {
          // Arrange
          when(
            () => mockFetchShippingConfigUseCase(),
          ).thenAnswer((_) async => NetworkFailure(Exception('error')));
          // Act
          await sut.fetchShippingConfig();
          // Assert
          expect(sut.shippingConfig, null);
          verify(() => mockFetchShippingConfigUseCase()).called(1);
          verifyNoMoreInteractions(mockFetchShippingConfigUseCase);
        },
      );
    });

    group('setAddress & Local Storage Saving', () {
      test(
        'should set address and save to local storage if saveAddress is true',
        () async {
          // Arrange
          when(
            () => mockLocalStorageService.saveAddress(any()),
          ).thenAnswer((_) async {});
          // Act
          sut.setAddress(tAddress);
          // Assert
          expect(sut.address, tAddress);
          verify(() => mockLocalStorageService.saveAddress(any())).called(1);
          verifyNoMoreInteractions(mockLocalStorageService);
        },
      );

      test(
        'should not save to local storage if saveAddress is false',
        () async {
          // Arrange
          sut.saveAddress = false;
          when(
            () => mockLocalStorageService.saveAddress(any()),
          ).thenAnswer((_) async {});
          // Act
          sut.setAddress(tAddress);
          // Assert
          expect(sut.address, tAddress);
          verifyNoMoreInteractions(mockLocalStorageService);
          verifyNever(() => mockLocalStorageService.saveAddress(any()));
        },
      );
    });

    group('getAddressFromLocalStorage', () {
      test(
        'should populate address from local storage if data exists',
        () async {
          // Arrange
          when(
            () => mockLocalStorageService.getAddress(),
          ).thenReturn(jsonEncode(tAddressMap));
          // Act
          sut.getAddressFromLocalStorage();
          // Assert
          expect(sut.address, tAddress);
          verify(() => mockLocalStorageService.getAddress()).called(1);
          verifyNoMoreInteractions(mockLocalStorageService);
        },
      );

      test(
        'should not populate address from local storage if data does not exist',
        () async {
          // Arrange
          when(() => mockLocalStorageService.getAddress()).thenReturn('');
          // Act
          sut.getAddressFromLocalStorage();
          // Assert
          expect(sut.address, null);
          verify(() => mockLocalStorageService.getAddress()).called(1);
          verifyNoMoreInteractions(mockLocalStorageService);
        },
      );
    });

    group('Subtotal Calculation', () {
      test('should calculate subtotal correctly', () async {
        // Arrange
        sut.setProducts(tProducts);
        // Act
        final subtotal = sut.subtotal;
        // Assert
        expect(subtotal, 250);
      });
    });

    group('addOrder', () {
      void setupCubitData() {
        sut.saveAddress = false;
        sut.setProducts(tProducts);
        sut.setAddress(tAddress);
        sut.setPaymentOption(tPaymentOption);
        when(() => mockLocalStorageService.getUid()).thenReturn('user_123');
      }

      blocTest(
        'emits [AddOrderLoading, AddOrderSuccess] when order is added successfully',
        build: () => sut,
        setUp: () {
          setupCubitData();
          when(
            () => mockAddOrderUseCase(any()),
          ).thenAnswer((_) async => const NetworkSuccess<void>());
        },
        act: (CheckoutCubit cubit) => cubit.addOrder(),
        expect: () => [isA<AddOrderLoading>(), isA<AddOrderSuccess>()],
        verify: (_) {
          verify(() => mockAddOrderUseCase(any())).called(1);
          verifyNoMoreInteractions(mockAddOrderUseCase);
          verify(() => mockLocalStorageService.getUid()).called(1);
          verifyNoMoreInteractions(mockLocalStorageService);
        },
      );

      blocTest(
        'emits [AddOrderLoading, AddOrderFailure] when order addition fails',
        build: () => sut,
        setUp: () {
          setupCubitData();
          when(
            () => mockAddOrderUseCase(any()),
          ).thenAnswer((_) async => NetworkFailure(Exception('error')));
        },
        act: (CheckoutCubit cubit) => cubit.addOrder(),
        expect: () => [isA<AddOrderLoading>(), isA<AddOrderFailure>()],
        verify: (_) {
          verify(() => mockAddOrderUseCase(any())).called(1);
          verifyNoMoreInteractions(mockAddOrderUseCase);
          verify(() => mockLocalStorageService.getUid()).called(1);
          verifyNoMoreInteractions(mockLocalStorageService);
          verifyNever(() => mockLocalStorageService.saveAddress(any()));
          verifyNever(() => mockLocalStorageService.getAddress());
        },
      );
    });
  });
}
