import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/clear_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/get_products_in_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/remove_item_from_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/update_item_quantity_use_case.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/fetch_shipping_config_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockAddItemToCartUseCase extends Mock implements AddItemToCartUseCase {}

class MockRemoveItemFromCartUseCase extends Mock
    implements RemoveItemFromCartUseCase {}

class MockGetProductsInCartUseCase extends Mock
    implements GetProductsInCartUseCase {}

class MockUpdateItemQuantityUseCase extends Mock
    implements UpdateItemQuantityUseCase {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

class MockFetchShippingConfigUseCase extends Mock
    implements FetchShippingConfigUseCase {}

void main() {
  late MockAddItemToCartUseCase mockAddItemToCartUseCase;
  late MockRemoveItemFromCartUseCase mockRemoveItemFromCartUseCase;
  late MockGetProductsInCartUseCase mockGetProductsInCartUseCase;
  late MockUpdateItemQuantityUseCase mockUpdateItemQuantityUseCase;
  late MockClearCartUseCase mockClearCartUseCase;
  late MockFetchShippingConfigUseCase mockFetchShippingConfigUseCase;
  late CartCubit sut;

  const tFailure = ServerFailure(error: 'An unexpected error occurred');

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
  const tCartItem2 = CartItemEntity(fruitEntity: tFruit2, quantity: 1); // 15.0

  const tShippingConfig = ShippingConfigEntity(
    shippingCost: 30.0,
    freeShippingThreshold: 200.0,
  );

  setUp(() {
    mockAddItemToCartUseCase = MockAddItemToCartUseCase();
    mockRemoveItemFromCartUseCase = MockRemoveItemFromCartUseCase();
    mockGetProductsInCartUseCase = MockGetProductsInCartUseCase();
    mockUpdateItemQuantityUseCase = MockUpdateItemQuantityUseCase();
    mockClearCartUseCase = MockClearCartUseCase();
    mockFetchShippingConfigUseCase = MockFetchShippingConfigUseCase();

    when(() => mockFetchShippingConfigUseCase())
        .thenAnswer((_) async => const NetworkSuccess(tShippingConfig));

    sut = CartCubit(
      mockAddItemToCartUseCase,
      mockRemoveItemFromCartUseCase,
      mockGetProductsInCartUseCase,
      mockUpdateItemQuantityUseCase,
      mockClearCartUseCase,
      mockFetchShippingConfigUseCase,
      debounceDuration: Duration.zero,
    );
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be CartInitial', () {
    // Assert
    expect(sut.state, isA<CartInitial>());
    expect(sut.productsInCart, isEmpty);
    expect(sut.shippingConfig, isNull);
  });

  group('getProductsInCart', () {
    blocTest<CartCubit, CartState>(
      'should emit [CartLoading, CartSuccess] and populate items when remote call succeeds',
      build: () {
        when(() => mockGetProductsInCartUseCase())
            .thenAnswer((_) async => const NetworkSuccess([tCartItem1, tCartItem2]));
        return sut;
      },
      act: (cubit) => cubit.getProductsInCart(),
      expect: () => [
        isA<CartLoading>(),
        isA<CartSuccess>()
            .having((s) => s.items.length, 'items count', 2)
            .having((s) => s.totalPrice, 'totalPrice', 65.0)
            .having((s) => s.totalItemCount, 'totalItemCount', 2),
      ],
      verify: (_) {
        verify(() => mockGetProductsInCartUseCase()).called(1);
        verify(() => mockFetchShippingConfigUseCase()).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'should not emit CartLoading when needLoading is false',
      build: () {
        when(() => mockGetProductsInCartUseCase())
            .thenAnswer((_) async => const NetworkSuccess([tCartItem1]));
        return sut;
      },
      act: (cubit) => cubit.getProductsInCart(needLoading: false),
      expect: () => [
        isA<CartSuccess>().having((s) => s.items.length, 'items count', 1),
      ],
    );

    blocTest<CartCubit, CartState>(
      'should emit [CartLoading, CartFailure] when remote call fails',
      build: () {
        when(() => mockGetProductsInCartUseCase())
            .thenAnswer((_) async => const NetworkFailure(tFailure));
        return sut;
      },
      act: (cubit) => cubit.getProductsInCart(),
      expect: () => [
        isA<CartLoading>(),
        isA<CartFailure>().having(
          (s) => s.errorMessage,
          'errorMessage',
          tFailure.error,
        ),
      ],
    );

    blocTest<CartCubit, CartState>(
      'should immediately emit CartSuccess without calling use case when _productsInCart is already populated',
      build: () => sut,
      seed: () => CartSuccess(
        items: const [tCartItem1],
        totalPrice: 50.0,
        totalItemCount: 1,
      ),
      setUp: () {
        // Populate internal list via addItemToCart
        when(
          () => mockAddItemToCartUseCase.call(any(), quantity: any(named: 'quantity')),
        ).thenAnswer((_) async => const NetworkSuccess(null));
      },
      act: (cubit) async {
        await cubit.addItemToCart(tFruit1);
        await cubit.getProductsInCart();
      },
      verify: (_) {
        verifyNever(() => mockGetProductsInCartUseCase());
      },
    );
  });

  group('addItemToCart', () {
    blocTest<CartCubit, CartState>(
      'should emit CartSuccess with itemAlreadyExists: true when item is already in cart',
      build: () => sut,
      setUp: () {
        when(
          () => mockAddItemToCartUseCase.call(any(), quantity: any(named: 'quantity')),
        ).thenAnswer((_) async => const NetworkSuccess(null));
      },
      act: (cubit) async {
        await cubit.addItemToCart(tFruit1);
        await cubit.addItemToCart(tFruit1);
      },
      skip: 1, // Skip the first addItemToCart emissions
      expect: () => [
        isA<CartSuccess>()
            .having((s) => s.itemAlreadyExists, 'itemAlreadyExists', true),
      ],
      verify: (_) {
        verify(() => mockAddItemToCartUseCase.call(tFruit1.code, quantity: 1)).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'should optimistically add item and emit CartSuccess with newItemAdded: true when use case succeeds',
      build: () {
        when(
          () => mockAddItemToCartUseCase.call(any(), quantity: any(named: 'quantity')),
        ).thenAnswer((_) async => const NetworkSuccess(null));
        return sut;
      },
      act: (cubit) => cubit.addItemToCart(tFruit1, quantity: 2),
      expect: () => [
        isA<CartSuccess>()
            .having((s) => s.newItemAdded, 'newItemAdded', true)
            .having((s) => s.items.length, 'items count', 1)
            .having((s) => s.totalPrice, 'totalPrice', 50.0)
            .having((s) => s.items.first.quantity, 'quantity', 2),
      ],
      verify: (_) {
        expect(sut.isInCart(tFruit1.code), isTrue);
        expect(sut.getCartItem(tFruit1.code)?.quantity, 2);
        verify(
          () => mockAddItemToCartUseCase.call(tFruit1.code, quantity: 2),
        ).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'should revert optimistic addition and emit CartFailure when use case fails',
      build: () {
        when(
          () => mockAddItemToCartUseCase.call(any(), quantity: any(named: 'quantity')),
        ).thenAnswer((_) async => const NetworkFailure(tFailure));
        return sut;
      },
      act: (cubit) => cubit.addItemToCart(tFruit1),
      expect: () => [
        isA<CartSuccess>().having((s) => s.newItemAdded, 'newItemAdded', true),
        isA<CartSuccess>().having((s) => s.items, 'items', isEmpty),
        isA<CartFailure>().having(
          (s) => s.errorMessage,
          'errorMessage',
          tFailure.error,
        ),
      ],
      verify: (_) {
        expect(sut.isInCart(tFruit1.code), isFalse);
        expect(sut.getCartItem(tFruit1.code), isNull);
      },
    );
  });

  group('removeItemFromCart', () {
    blocTest<CartCubit, CartState>(
      'should do nothing when item does not exist in cart',
      build: () => sut,
      act: (cubit) => cubit.removeItemFromCart('NON_EXISTING'),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockRemoveItemFromCartUseCase.call(any()));
      },
    );

    blocTest<CartCubit, CartState>(
      'should optimistically remove item and emit CartSuccess with itemRemoved: true when use case succeeds',
      build: () {
        when(
          () => mockAddItemToCartUseCase.call(any(), quantity: any(named: 'quantity')),
        ).thenAnswer((_) async => const NetworkSuccess(null));
        when(
          () => mockRemoveItemFromCartUseCase.call(any()),
        ).thenAnswer((_) async => const NetworkSuccess(null));
        return sut;
      },
      act: (cubit) async {
        await cubit.addItemToCart(tFruit1);
        await cubit.removeItemFromCart(tFruit1.code);
      },
      skip: 1, // Skip addItemToCart emission
      expect: () => [
        isA<CartSuccess>()
            .having((s) => s.itemRemoved, 'itemRemoved', true)
            .having((s) => s.items, 'items', isEmpty),
      ],
      verify: (_) {
        expect(sut.isInCart(tFruit1.code), isFalse);
        verify(() => mockRemoveItemFromCartUseCase.call(tFruit1.code)).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'should revert optimistic removal and emit CartFailure when use case fails',
      build: () {
        when(
          () => mockAddItemToCartUseCase.call(any(), quantity: any(named: 'quantity')),
        ).thenAnswer((_) async => const NetworkSuccess(null));
        when(
          () => mockRemoveItemFromCartUseCase.call(any()),
        ).thenAnswer((_) async => const NetworkFailure(tFailure));
        return sut;
      },
      act: (cubit) async {
        await cubit.addItemToCart(tFruit1);
        await cubit.removeItemFromCart(tFruit1.code);
      },
      skip: 1, // Skip addItemToCart emission
      expect: () => [
        isA<CartSuccess>().having((s) => s.itemRemoved, 'itemRemoved', true),
        isA<CartSuccess>().having((s) => s.items.length, 'reverted items', 1),
        isA<CartFailure>().having(
          (s) => s.errorMessage,
          'errorMessage',
          tFailure.error,
        ),
      ],
      verify: (_) {
        expect(sut.isInCart(tFruit1.code), isTrue);
      },
    );
  });

  group('clearCart', () {
    blocTest<CartCubit, CartState>(
      'should emit [CartLoading, CartSuccess] and clear products when use case succeeds',
      build: () {
        when(() => mockClearCartUseCase())
            .thenAnswer((_) async => const NetworkSuccess(null));
        return sut;
      },
      setUp: () {
        when(
          () => mockAddItemToCartUseCase.call(any(), quantity: any(named: 'quantity')),
        ).thenAnswer((_) async => const NetworkSuccess(null));
      },
      act: (cubit) async {
        await cubit.addItemToCart(tFruit1);
        await cubit.clearCart();
      },
      skip: 1, // Skip addItemToCart emission
      expect: () => [
        isA<CartLoading>(),
        isA<CartSuccess>().having((s) => s.items, 'items', isEmpty),
      ],
      verify: (_) {
        expect(sut.productsInCart, isEmpty);
        verify(() => mockClearCartUseCase()).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'should emit [CartLoading, CartFailure] when use case fails',
      build: () {
        when(() => mockClearCartUseCase())
            .thenAnswer((_) async => const NetworkFailure(tFailure));
        return sut;
      },
      act: (cubit) => cubit.clearCart(),
      expect: () => [
        isA<CartLoading>(),
        isA<CartFailure>().having(
          (s) => s.errorMessage,
          'errorMessage',
          tFailure.error,
        ),
      ],
    );
  });

  group('incrementItemQuantity & decrementItemQuantity', () {
    blocTest<CartCubit, CartState>(
      'should increment quantity optimistically and sync with server via debounce',
      build: () {
        when(
          () => mockAddItemToCartUseCase.call(any(), quantity: any(named: 'quantity')),
        ).thenAnswer((_) async => const NetworkSuccess(null));
        when(
          () => mockUpdateItemQuantityUseCase.call(
            productId: any(named: 'productId'),
            newQuantity: any(named: 'newQuantity'),
          ),
        ).thenAnswer((_) async => const NetworkSuccess(null));
        return sut;
      },
      act: (cubit) async {
        await cubit.addItemToCart(tFruit1, quantity: 1);
        cubit.incrementItemQuantity(tFruit1.code);
        // Wait for debounce timer (zero duration)
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      skip: 1, // Skip addItemToCart emission
      expect: () => [
        isA<CartSuccess>().having(
          (s) => s.items.first.quantity,
          'incremented quantity',
          2,
        ),
      ],
      verify: (_) {
        expect(sut.getCartItem(tFruit1.code)?.quantity, 2);
        verify(
          () => mockUpdateItemQuantityUseCase.call(
            productId: tFruit1.code,
            newQuantity: 2,
          ),
        ).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'should decrement quantity optimistically and sync with server',
      build: () {
        when(
          () => mockAddItemToCartUseCase.call(any(), quantity: any(named: 'quantity')),
        ).thenAnswer((_) async => const NetworkSuccess(null));
        when(
          () => mockUpdateItemQuantityUseCase.call(
            productId: any(named: 'productId'),
            newQuantity: any(named: 'newQuantity'),
          ),
        ).thenAnswer((_) async => const NetworkSuccess(null));
        return sut;
      },
      act: (cubit) async {
        await cubit.addItemToCart(tFruit1, quantity: 3);
        cubit.decrementItemQuantity(tFruit1.code);
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      skip: 1, // Skip addItemToCart emission
      expect: () => [
        isA<CartSuccess>().having(
          (s) => s.items.first.quantity,
          'decremented quantity',
          2,
        ),
      ],
      verify: (_) {
        expect(sut.getCartItem(tFruit1.code)?.quantity, 2);
        verify(
          () => mockUpdateItemQuantityUseCase.call(
            productId: tFruit1.code,
            newQuantity: 2,
          ),
        ).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'should call removeItemFromCart when decrementing quantity to 0',
      build: () {
        when(
          () => mockAddItemToCartUseCase.call(any(), quantity: any(named: 'quantity')),
        ).thenAnswer((_) async => const NetworkSuccess(null));
        when(
          () => mockRemoveItemFromCartUseCase.call(any()),
        ).thenAnswer((_) async => const NetworkSuccess(null));
        return sut;
      },
      act: (cubit) async {
        await cubit.addItemToCart(tFruit1, quantity: 1);
        cubit.decrementItemQuantity(tFruit1.code);
      },
      skip: 1, // Skip addItemToCart emission
      expect: () => [
        isA<CartSuccess>().having((s) => s.itemRemoved, 'itemRemoved', true),
      ],
      verify: (_) {
        expect(sut.isInCart(tFruit1.code), isFalse);
        verify(() => mockRemoveItemFromCartUseCase.call(tFruit1.code)).called(1);
        verifyNever(
          () => mockUpdateItemQuantityUseCase.call(
            productId: any(named: 'productId'),
            newQuantity: any(named: 'newQuantity'),
          ),
        );
      },
    );

    blocTest<CartCubit, CartState>(
      'should revert to baseline quantity and emit CartFailure when server sync fails',
      build: () {
        when(
          () => mockAddItemToCartUseCase.call(any(), quantity: any(named: 'quantity')),
        ).thenAnswer((_) async => const NetworkSuccess(null));
        when(
          () => mockUpdateItemQuantityUseCase.call(
            productId: any(named: 'productId'),
            newQuantity: any(named: 'newQuantity'),
          ),
        ).thenAnswer((_) async => const NetworkFailure(tFailure));
        return sut;
      },
      act: (cubit) async {
        await cubit.addItemToCart(tFruit1, quantity: 1);
        cubit.incrementItemQuantity(tFruit1.code);
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      skip: 1, // Skip addItemToCart emission
      expect: () => [
        isA<CartSuccess>().having(
          (s) => s.items.first.quantity,
          'optimistic quantity',
          2,
        ),
        isA<CartSuccess>().having(
          (s) => s.items.first.quantity,
          'reverted quantity',
          1,
        ),
        isA<CartFailure>().having(
          (s) => s.errorMessage,
          'errorMessage',
          tFailure.error,
        ),
      ],
      verify: (_) {
        expect(sut.getCartItem(tFruit1.code)?.quantity, 1);
      },
    );

    test('should do nothing when incrementing or decrementing non-existent product', () {
      // Act
      sut.incrementItemQuantity('NON_EXISTING');
      sut.decrementItemQuantity('NON_EXISTING');

      // Assert
      expect(sut.state, isA<CartInitial>());
      verifyNever(
        () => mockUpdateItemQuantityUseCase.call(
          productId: any(named: 'productId'),
          newQuantity: any(named: 'newQuantity'),
        ),
      );
    });
  });
}
