import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/get_cart_items_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/get_products_in_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/remove_item_from_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/update_item_quantity_use_case.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAddItemToCartUseCase extends Mock implements AddItemToCartUseCase {}

class MockRemoveItemFromCartUseCase extends Mock
    implements RemoveItemFromCartUseCase {}

class MockGetCartItemsUseCase extends Mock implements GetCartItemsUseCase {}

class MockUpdateItemQuantityUseCase extends Mock
    implements UpdateItemQuantityUseCase {}

class MockGetProductsInCartUseCase extends Mock
    implements GetProductsInCartUseCase {}

void main() {
  late CartCubit sut;
  late MockAddItemToCartUseCase mockAddItemToCartUseCase;
  late MockRemoveItemFromCartUseCase mockRemoveItemFromCartUseCase;
  late MockGetProductsInCartUseCase mockGetProductsInCartUseCase;
  late MockUpdateItemQuantityUseCase mockUpdateItemQuantityUseCase;
  late MockGetCartItemsUseCase mockGetCartItemsUseCase;

  const tProductId = 'apple';
  final tFruitEntity = FruitEntity(
    code: tProductId,
    name: 'Apple',
    price: 10.0,
    imagePath: 'image',
    description: 'desc',
    isFeatured: false,
  );

  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(
    Exception("permission-denied"),
  );

  List<CartItemEntity> tProductsInCart = [
    CartItemEntity(fruitEntity: tFruitEntity, quantity: 2),
  ];

  final tSuccessResponse = NetworkSuccess<List<CartItemEntity>>(
    tProductsInCart,
  );
  final tFailureResponse = NetworkFailure<List<CartItemEntity>>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockAddItemToCartUseCase = MockAddItemToCartUseCase();
    mockRemoveItemFromCartUseCase = MockRemoveItemFromCartUseCase();
    mockGetProductsInCartUseCase = MockGetProductsInCartUseCase();
    mockUpdateItemQuantityUseCase = MockUpdateItemQuantityUseCase();
    mockGetCartItemsUseCase = MockGetCartItemsUseCase();
    sut = CartCubit(
      mockAddItemToCartUseCase,
      mockRemoveItemFromCartUseCase,
      mockGetProductsInCartUseCase,
      mockUpdateItemQuantityUseCase,
      mockGetCartItemsUseCase,
    );
  });

  group('cart cubit', () {
    test('initial state should be CartInitial', () {
      expect(sut.state, isA<CartInitial>());
    });

    group('addItemToCart', () {
      blocTest<CartCubit, CartState>(
        'emits [CartSuccess] with newItemAdded equal true when addItemToCart succeeds',
        build: () => sut,
        setUp: () {
          when(
            () => mockAddItemToCartUseCase.call(tProductId),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
          when(
            () => mockGetProductsInCartUseCase.call(any()),
          ).thenAnswer((_) async => tSuccessResponse);
        },
        act: (cubit) => cubit.addItemToCart(tProductId),
        expect: () => [
          isA<CartSuccess>()
              .having((state) => state.items, 'items', tProductsInCart)
              .having((state) => state.totalItemCount, 'totalItemCount', 1)
              .having((state) => state.totalPrice, 'totalPrice', 20.0)
              .having((state) => state.newItemAdded, 'newItemAdded', true),
        ],
        verify: (_) {
          verifyInOrder([
            () => mockAddItemToCartUseCase.call(tProductId),
            () => mockGetProductsInCartUseCase.call(any()),
          ]);
          verifyNoMoreInteractions(mockAddItemToCartUseCase);
          verifyNoMoreInteractions(mockGetProductsInCartUseCase);
        },
      );

      blocTest<CartCubit, CartState>(
        'emits [CartFailure] when addItemToCart fails',
        build: () => sut,
        setUp: () {
          when(
            () => mockAddItemToCartUseCase.call(tProductId),
          ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
        },
        act: (cubit) => cubit.addItemToCart(tProductId),
        expect: () => [
          isA<CartFailure>().having(
            (state) => state.errorMessage,
            'exception',
            equals(getErrorMessage(tFailureResponse)),
          ),
        ],
        verify: (_) {
          verify(() => mockAddItemToCartUseCase.call(tProductId)).called(1);
          verifyNoMoreInteractions(mockAddItemToCartUseCase);
        },
      );

      blocTest<CartCubit, CartState>(
        'emits [CartFailure] when getProductsInCart fails',
        build: () => sut,
        setUp: () {
          when(
            () => mockAddItemToCartUseCase.call(tProductId),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
          when(
            () => mockGetProductsInCartUseCase.call(any()),
          ).thenAnswer((_) async => tFailureResponse);
        },
        act: (cubit) => cubit.addItemToCart(tProductId),
        expect: () => [
          isA<CartFailure>().having(
            (state) => state.errorMessage,
            'exception',
            equals(getErrorMessage(tFailureResponse)),
          ),
        ],
        verify: (_) {
          verifyInOrder([
            () => mockAddItemToCartUseCase.call(tProductId),
            () => mockGetProductsInCartUseCase.call(any()),
          ]);
          verifyNoMoreInteractions(mockAddItemToCartUseCase);
          verifyNoMoreInteractions(mockGetProductsInCartUseCase);
        },
      );
    });

    group('removeItemFromCart', () {
      blocTest<CartCubit, CartState>(
        'emits [CartSuccess] when removeItemFromCart and subsequent getCartItems are successful',
        build: () => sut,
        setUp: () {
          when(
            () => mockRemoveItemFromCartUseCase.call(tProductId),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
          when(
            () => mockGetProductsInCartUseCase.call(any()),
          ).thenAnswer((_) async => tSuccessResponse);
        },
        act: (cubit) => cubit.removeItemFromCart(tProductId),
        expect: () => [
          isA<CartSuccess>()
              .having((state) => state.items, 'items', tProductsInCart)
              .having((state) => state.totalItemCount, 'totalItemCount', 1)
              .having((state) => state.totalPrice, 'totalPrice', 20.0)
              .having((state) => state.newItemAdded, 'newItemAdded', false),
        ],
        verify: (_) {
          verifyInOrder([
            () => mockRemoveItemFromCartUseCase.call(tProductId),
            () => mockGetProductsInCartUseCase.call(any()),
          ]);
          verifyNoMoreInteractions(mockRemoveItemFromCartUseCase);
          verifyNoMoreInteractions(mockGetProductsInCartUseCase);
        },
      );

      blocTest<CartCubit, CartState>(
        'emits [CartFailure] when removeItemFromCart fails',
        build: () => sut,
        setUp: () {
          when(
            () => mockRemoveItemFromCartUseCase.call(tProductId),
          ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
        },
        act: (cubit) => cubit.removeItemFromCart(tProductId),
        expect: () => [
          isA<CartFailure>().having(
            (state) => state.errorMessage,
            'exception',
            equals(getErrorMessage(tFailureResponse)),
          ),
        ],
        verify: (_) {
          verify(
            () => mockRemoveItemFromCartUseCase.call(tProductId),
          ).called(1);
          verifyNoMoreInteractions(mockRemoveItemFromCartUseCase);
        },
      );

      blocTest<CartCubit, CartState>(
        'emits [CartFailure] when getProductsInCart fails',
        build: () => sut,
        setUp: () {
          when(
            () => mockRemoveItemFromCartUseCase.call(tProductId),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
          when(
            () => mockGetProductsInCartUseCase.call(any()),
          ).thenAnswer((_) async => tFailureResponse);
        },
        act: (cubit) => cubit.removeItemFromCart(tProductId),
        expect: () => [
          isA<CartFailure>().having(
            (state) => state.errorMessage,
            'exception',
            equals(getErrorMessage(tFailureResponse)),
          ),
        ],
        verify: (_) {
          verifyInOrder([
            () => mockRemoveItemFromCartUseCase.call(tProductId),
            () => mockGetProductsInCartUseCase.call(any()),
          ]);
          verifyNoMoreInteractions(mockRemoveItemFromCartUseCase);
          verifyNoMoreInteractions(mockGetProductsInCartUseCase);
        },
      );
    });

    group('getCartItems', () {
      final cartItems = [
        {'fruitCode': tProductId, 'quantity': 1},
        {'fruitCode': 'banana_yellow', 'quantity': 10},
      ];

      final tSuccessResponseOfTypeListMapStringDynamic =
          NetworkSuccess<List<Map<String, dynamic>>>(cartItems);
      final tFailureResponseOfTypeListMapStringDynamic =
          NetworkFailure<List<Map<String, dynamic>>>(
            Exception("permission-denied"),
          );
      blocTest<CartCubit, CartState>(
        'emits [GetCartItemsLoading, GetCartItemsSuccess] when getCartItems is successful',
        build: () => sut,
        setUp: () {
          when(
            () => mockGetCartItemsUseCase.call(),
          ).thenAnswer((_) async => tSuccessResponseOfTypeListMapStringDynamic);
        },
        act: (cubit) => cubit.getCartItems(),
        expect: () => [isA<GetCartItemsLoading>(), isA<GetCartItemsSuccess>()],
        verify: (_) {
          verify(() => mockGetCartItemsUseCase.call()).called(1);
          verifyNoMoreInteractions(mockGetCartItemsUseCase);
        },
      );

      blocTest<CartCubit, CartState>(
        'emits [GetCartItemsLoading, GetCartItemsFailure] when getCartItems fails',
        build: () => sut,
        setUp: () {
          when(
            () => mockGetCartItemsUseCase.call(),
          ).thenAnswer((_) async => tFailureResponseOfTypeListMapStringDynamic);
        },
        act: (cubit) => cubit.getCartItems(),
        expect: () => [
          isA<GetCartItemsLoading>(),
          isA<GetCartItemsFailure>().having(
            (state) => state.errorMessage,
            'exception',
            equals(getErrorMessage(tFailureResponse)),
          ),
        ],
        verify: (_) {
          verify(() => mockGetCartItemsUseCase.call()).called(1);
          verifyNoMoreInteractions(mockGetCartItemsUseCase);
        },
      );
    });

    group("get products in cart", () {
      blocTest(
        'emits [CartLoading, CartSuccess] when getProductsInCart is successful and needLoading is true',
        build: () => sut,
        setUp: () {
          when(
            () => mockGetProductsInCartUseCase.call(any()),
          ).thenAnswer((_) async => tSuccessResponse);
        },
        act: (cubit) => cubit.getProductsInCart(needLoading: true),
        expect: () => [
          isA<CartLoading>(),
          isA<CartSuccess>()
              .having((state) => state.items, 'items', tProductsInCart)
              .having((state) => state.totalItemCount, 'totalItemCount', 1)
              .having((state) => state.totalPrice, 'totalPrice', 20.0)
              .having((state) => state.newItemAdded, 'newItemAdded', false),
        ],
        verify: (_) {
          verify(() => mockGetProductsInCartUseCase.call(any())).called(1);
          verifyNoMoreInteractions(mockGetProductsInCartUseCase);
        },
      );

      blocTest(
        'emits [CartSuccess] when getProductsInCart is successful and needLoading is false',
        build: () => sut,
        setUp: () {
          when(
            () => mockGetProductsInCartUseCase.call(any()),
          ).thenAnswer((_) async => tSuccessResponse);
        },
        act: (cubit) => cubit.getProductsInCart(needLoading: false),
        expect: () => [
          isA<CartSuccess>()
              .having((state) => state.items, 'items', tProductsInCart)
              .having((state) => state.totalItemCount, 'totalItemCount', 1)
              .having((state) => state.totalPrice, 'totalPrice', 20.0)
              .having((state) => state.newItemAdded, 'newItemAdded', false),
        ],
        verify: (_) {
          verify(() => mockGetProductsInCartUseCase.call(any())).called(1);
          verifyNoMoreInteractions(mockGetProductsInCartUseCase);
        },
      );

      blocTest(
        'emits [CartLoading,CartFailure] when getProductsInCart fails',
        build: () => sut,
        setUp: () {
          when(
            () => mockGetProductsInCartUseCase.call(any()),
          ).thenAnswer((_) async => tFailureResponse);
        },
        act: (cubit) => cubit.getProductsInCart(),
        expect: () => [
          isA<CartLoading>(),
          isA<CartFailure>().having(
            (state) => state.errorMessage,
            'exception',
            equals(getErrorMessage(tFailureResponse)),
          ),
        ],
        verify: (_) {
          verify(() => mockGetProductsInCartUseCase.call(any())).called(1);
          verifyNoMoreInteractions(mockGetProductsInCartUseCase);
        },
      );
    });

    group('Item Quantity Management', () {
      final tItemQty1 = CartItemEntity(fruitEntity: tFruitEntity, quantity: 1);
      final tItemQty2 = CartItemEntity(fruitEntity: tFruitEntity, quantity: 2);

      blocTest(
        'should emit [CartSuccess] with incremented quantity when increment succeeds',
        build: () => sut,
        setUp: () {
          when(
            () => mockGetProductsInCartUseCase.call(any()),
          ).thenAnswer((_) async => NetworkSuccess([tItemQty1]));
          when(
            () => mockUpdateItemQuantityUseCase.call(
              productId: tProductId,
              newQuantity: 2,
            ),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
        },
        act: (cubit) async {
          await cubit.getProductsInCart(needLoading: false);
          await cubit.incrementItemQuantity(tProductId);
        },
        expect: () => [
          isA<CartSuccess>().having(
            (s) => s.items.first.quantity,
            'init qty',
            1,
          ),
          isA<CartSuccess>().having(
            (s) => s.items.first.quantity,
            'optimistic qty',
            2,
          ),
        ],
        verify: (_) {
          verifyInOrder([
            () => mockGetProductsInCartUseCase.call(any()),
            () => mockUpdateItemQuantityUseCase.call(
              productId: tProductId,
              newQuantity: 2,
            ),
          ]);
          verifyNoMoreInteractions(mockGetProductsInCartUseCase);
          verifyNoMoreInteractions(mockUpdateItemQuantityUseCase);
        },
      );

      blocTest(
        'should emit optimistic update then REVERT to old quantity when increment fails',
        build: () => sut,
        setUp: () {
          when(
            () => mockGetProductsInCartUseCase.call(any()),
          ).thenAnswer((_) async => NetworkSuccess([tItemQty1]));
          when(
            () => mockUpdateItemQuantityUseCase.call(
              productId: any(named: 'productId'),
              newQuantity: any(named: 'newQuantity'),
            ),
          ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
        },
        act: (cubit) async {
          await cubit.getProductsInCart(needLoading: false);
          await cubit.incrementItemQuantity(tProductId);
        },
        expect: () => [
          isA<CartSuccess>().having((s) => s.items.first.quantity, 'init', 1),
          isA<CartSuccess>().having(
            (s) => s.items.first.quantity,
            'optimistic',
            2,
          ),
          isA<CartSuccess>().having(
            (s) => s.items.first.quantity,
            'reverted',
            1,
          ),
        ],
        verify: (_) {
          verifyInOrder([
            () => mockGetProductsInCartUseCase.call(any()),
            () => mockUpdateItemQuantityUseCase.call(
              productId: tProductId,
              newQuantity: 2,
            ),
          ]);
          verifyNoMoreInteractions(mockGetProductsInCartUseCase);
          verifyNoMoreInteractions(mockUpdateItemQuantityUseCase);
        },
      );

      blocTest(
        'should emit [CartSuccess] with decremented quantity when decrement succeeds',
        build: () => sut,
        setUp: () {
          when(
            () => mockGetProductsInCartUseCase.call(any()),
          ).thenAnswer((_) async => NetworkSuccess([tItemQty2]));
          when(
            () => mockUpdateItemQuantityUseCase.call(
              productId: tProductId,
              newQuantity: 1,
            ),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
        },
        act: (cubit) async {
          await cubit.getProductsInCart(needLoading: false);
          await cubit.decrementItemQuantity(tProductId);
        },
        expect: () => [
          isA<CartSuccess>().having(
            (s) => s.items.first.quantity,
            'init qty',
            2,
          ),
          isA<CartSuccess>().having(
            (s) => s.items.first.quantity,
            'optimistic qty',
            1,
          ),
        ],
        verify: (_) {
          verifyInOrder([
            () => mockGetProductsInCartUseCase.call(any()),
            () => mockUpdateItemQuantityUseCase.call(
              productId: tProductId,
              newQuantity: 1,
            ),
          ]);
          verifyNoMoreInteractions(mockGetProductsInCartUseCase);
          verifyNoMoreInteractions(mockUpdateItemQuantityUseCase);
        },
      );

      blocTest(
        'should call removeItemFromCart when quantity becomes 0',
        build: () => sut,
        setUp: () {
          when(
            () => mockRemoveItemFromCartUseCase.call(any()),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
          int callCount = 0;
          when(() => mockGetProductsInCartUseCase.call(any())).thenAnswer((
            _,
          ) async {
            callCount++;
            if (callCount == 1) {
              return NetworkSuccess([tItemQty1]);
            }
            return const NetworkSuccess([]);
          });
        },
        act: (cubit) async {
          await cubit.getProductsInCart(needLoading: false);
          await cubit.decrementItemQuantity(tProductId);
        },
        expect: () => [
          isA<CartSuccess>().having((s) => s.items.length, 'init', 1),
          isA<CartSuccess>().having((s) => s.items.length, 'removed', 0),
        ],
        verify: (_) {
          verifyInOrder([
            () => mockGetProductsInCartUseCase.call(any()),
            () => mockRemoveItemFromCartUseCase.call(tProductId),
            () => mockGetProductsInCartUseCase.call(any()),
          ]);
          verifyNoMoreInteractions(mockGetProductsInCartUseCase);
          verifyNoMoreInteractions(mockRemoveItemFromCartUseCase);
        },
      );

      blocTest(
        'should emit optimistic update then REVERT to old quantity when decrement fails',
        build: () => sut,
        setUp: () {
          when(
            () => mockGetProductsInCartUseCase.call(any()),
          ).thenAnswer((_) async => NetworkSuccess([tItemQty2]));
          when(
            () => mockUpdateItemQuantityUseCase.call(
              productId: any(named: 'productId'),
              newQuantity: any(named: 'newQuantity'),
            ),
          ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
        },
        act: (cubit) async {
          await cubit.getProductsInCart(needLoading: false);
          await cubit.decrementItemQuantity(tProductId);
        },
        expect: () => [
          isA<CartSuccess>().having((s) => s.items.first.quantity, 'init', 2),
          isA<CartSuccess>().having(
            (s) => s.items.first.quantity,
            'optimistic',
            1,
          ),
          isA<CartSuccess>().having(
            (s) => s.items.first.quantity,
            'reverted',
            2,
          ),
        ],
        verify: (_) {
          verifyInOrder([
            () => mockGetProductsInCartUseCase.call(any()),
            () => mockUpdateItemQuantityUseCase.call(
              productId: tProductId,
              newQuantity: 1,
            ),
          ]);
          verifyNoMoreInteractions(mockUpdateItemQuantityUseCase);
          verifyNoMoreInteractions(mockGetProductsInCartUseCase);
        },
      );
    });
  });
}
