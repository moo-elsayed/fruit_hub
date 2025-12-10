import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/order_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/domain/repo/checkout_repo.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/add_order_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckoutRepo extends Mock implements CheckoutRepo {}

void main() {
  late AddOrderUseCase sut;
  late MockCheckoutRepo mockCheckoutRepo;

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
    registerFallbackValue(tOrderEntity);
  });

  setUp(() {
    mockCheckoutRepo = MockCheckoutRepo();
    sut = AddOrderUseCase(mockCheckoutRepo);
  });

  group("AddOrderUseCase", () {
    test('should return NetworkSuccess when addOrder is successful', () async {
      // Arrange
      when(
        () => mockCheckoutRepo.addOrder(tOrderEntity),
      ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
      // Act
      final result = await sut.call(tOrderEntity);
      // Assert
      expect(result, tSuccessResponseOfTypeVoid);
      verify(() => mockCheckoutRepo.addOrder(tOrderEntity)).called(1);
      verifyNoMoreInteractions(mockCheckoutRepo);
    });

    test(
      'should return NetworkFailure when addOrder throws an exception',
      () async {
        // Arrange
        when(
          () => mockCheckoutRepo.addOrder(tOrderEntity),
        ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
        // Act
        final result = await sut.call(tOrderEntity);
        // Assert
        expect(result, tFailureResponseOfTypeVoid);
        expect(getErrorMessage(result), 'DataSource error');
        verify(() => mockCheckoutRepo.addOrder(tOrderEntity)).called(1);
        verifyNoMoreInteractions(mockCheckoutRepo);
      },
    );
  });
}
