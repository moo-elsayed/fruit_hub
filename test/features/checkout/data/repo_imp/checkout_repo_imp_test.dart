import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/checkout/data/data_sources/remote/checkout_remote_data_source.dart';
import 'package:fruit_hub/features/checkout/data/repo_imp/checkout_repo_imp.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/order_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutRemoteDataSource extends Mock
    implements CheckoutRemoteDataSource {}

void main() {
  late CheckoutRepoImp sut;
  late MockCheckoutRemoteDataSource mockCheckoutRemoteDataSource;

  final tShippingConfigEntity = const ShippingConfigEntity(shippingCost: 50.0);
  final tSuccessResponseOfTypeShippingConfigEntity =
      NetworkSuccess<ShippingConfigEntity>(tShippingConfigEntity);
  final tFailureResponseOfTypeShippingConfigEntity =
      NetworkFailure<ShippingConfigEntity>(Exception("permission-denied"));

  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tException = Exception('DataSource error');
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(tException);

  OrderEntity tOrderEntity = OrderEntity(
    uid: '123',
    products: [
      const CartItemEntity(
        fruitEntity: FruitEntity(
          code: '123',
          name: 'apple',
          imagePath: 'path',
          price: 10.0,
          description: 'description',
        ),
        quantity: 1,
      ),
    ],
    address: const AddressEntity(
      streetName: 'streetName',
      buildingNumber: 'buildingNumber',
      floorNumber: 'floorNumber',
      apartmentNumber: 'apartmentNumber',
      city: 'city',
      email: 'email',
      phone: 'phone',
      name: 'name',
    ),
    paymentOption: const PaymentOptionEntity(
      option: 'option',
      shippingCost: 50.0,
    ),
  );

  setUpAll(() {
    registerFallbackValue(const ShippingConfigEntity());
    registerFallbackValue(tOrderEntity);
  });

  setUp(() {
    mockCheckoutRemoteDataSource = MockCheckoutRemoteDataSource();
    sut = CheckoutRepoImp(mockCheckoutRemoteDataSource);
  });

  group("CheckoutRepoImp", () {
    group("fetchShippingConfig", () {
      test(
        'should return NetworkSuccess when fetchShippingConfig is successful',
        () async {
          // Arrange
          when(
            () => mockCheckoutRemoteDataSource.fetchShippingConfig(),
          ).thenAnswer((_) async => tSuccessResponseOfTypeShippingConfigEntity);
          // Act
          final result = await sut.fetchShippingConfig();
          // Assert
          expect(result, tSuccessResponseOfTypeShippingConfigEntity);
          verify(
            () => mockCheckoutRemoteDataSource.fetchShippingConfig(),
          ).called(1);
          verifyNoMoreInteractions(mockCheckoutRemoteDataSource);
        },
      );

      test(
        'should return NetworkFailure when fetchShippingConfig throws an exception',
        () async {
          // Arrange
          when(
            () => mockCheckoutRemoteDataSource.fetchShippingConfig(),
          ).thenAnswer((_) async => tFailureResponseOfTypeShippingConfigEntity);
          // Act
          final result = await sut.fetchShippingConfig();
          // Assert
          expect(result, tFailureResponseOfTypeShippingConfigEntity);
          verify(
            () => mockCheckoutRemoteDataSource.fetchShippingConfig(),
          ).called(1);
          verifyNoMoreInteractions(mockCheckoutRemoteDataSource);
        },
      );
    });

    group("addOrder", () {
      test(
        'should return NetworkSuccess when addOrder is successful',
        () async {
          // Arrange
          when(
            () => mockCheckoutRemoteDataSource.addOrder(tOrderEntity),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
          // Act
          final result = await sut.addOrder(tOrderEntity);
          // Assert
          expect(result, tSuccessResponseOfTypeVoid);
          verify(
            () => mockCheckoutRemoteDataSource.addOrder(tOrderEntity),
          ).called(1);
          verifyNoMoreInteractions(mockCheckoutRemoteDataSource);
        },
      );

      test(
        'should return NetworkFailure when addOrder throws an exception',
        () async {
          // Arrange
          when(
            () => mockCheckoutRemoteDataSource.addOrder(tOrderEntity),
          ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
          // Act
          final result = await sut.addOrder(tOrderEntity);
          // Assert
          expect(result, tFailureResponseOfTypeVoid);
          expect(getErrorMessage(result), 'DataSource error');
          verify(
            () => mockCheckoutRemoteDataSource.addOrder(tOrderEntity),
          ).called(1);
          verifyNoMoreInteractions(mockCheckoutRemoteDataSource);
        },
      );
    });
  });
}
