// import 'package:bloc_test/bloc_test.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:fruit_hub/core/entities/fruit_entity.dart';
// import 'package:fruit_hub/core/helpers/functions.dart';
// import 'package:fruit_hub/core/helpers/network_response.dart';
// import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
// import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
// import 'package:fruit_hub/features/cart/domain/use_cases/get_products_in_cart_use_case.dart';
// import 'package:fruit_hub/features/cart/domain/use_cases/remove_item_from_cart_use_case.dart';
// import 'package:fruit_hub/features/cart/domain/use_cases/update_item_quantity_use_case.dart';
// import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
// import 'package:mocktail/mocktail.dart';
//
// class MockAddItemToCartUseCase extends Mock implements AddItemToCartUseCase {}
//
// class MockRemoveItemFromCartUseCase extends Mock
//     implements RemoveItemFromCartUseCase {}
//
// class MockGetCartItemsUseCase extends Mock implements GetCartItemsUseCase {}
//
// class MockUpdateItemQuantityUseCase extends Mock
//     implements UpdateItemQuantityUseCase {}
//
// class MockFruitEntity extends Mock implements FruitEntity {}
//
// void main() {
//   late CartCubit sut;
//   late MockAddItemToCartUseCase mockAddItemToCartUseCase;
//   late MockRemoveItemFromCartUseCase mockRemoveItemFromCartUseCase;
//   late MockGetCartItemsUseCase mockGetCartItemsUseCase;
//   late MockUpdateItemQuantityUseCase mockUpdateItemQuantityUseCase;
//   late CartItemEntity tCartItemEntity;
//
//   final tMockFruit = MockFruitEntity();
//   late CartItemEntity tInitialItem;
//   late CartSuccess tInitialState;
//
//   const tProductId = 'apple';
//   const tInitialQuantity = 2;
//   const tNewQuantity = 3;
//
//   late CartItemEntity tUpdatedItem;
//   late List<CartItemEntity> tUpdatedList;
//   late NetworkSuccess<List<CartItemEntity>> tSuccessGetItemsResponse;
//
//   final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
//   final tFailureResponseOfTypeVoid = NetworkFailure<void>(
//     Exception("permission-denied"),
//   );
//
//   List<CartItemEntity> tCartItems = [
//     CartItemEntity(fruitEntity: FruitEntity(price: 4), quantity: 2),
//     CartItemEntity(fruitEntity: FruitEntity(price: 5), quantity: 3),
//     CartItemEntity(fruitEntity: FruitEntity(price: 6), quantity: 4),
//   ];
//
//   final tSuccessResponse = NetworkSuccess<List<CartItemEntity>>(tCartItems);
//   final tFailureResponse = NetworkFailure<List<CartItemEntity>>(
//     Exception("permission-denied"),
//   );
//
//   const tNewQuantityDec = 1;
//   late CartItemEntity tUpdatedItemDec;
//   late List<CartItemEntity> tUpdatedListDec;
//   late NetworkSuccess<List<CartItemEntity>> tSuccessGetItemsResponseDec;
//   late CartItemEntity tInitialItemQ1;
//   late CartSuccess tInitialStateQ1;
//   final List<CartItemEntity> tUpdatedListQ0 = const [];
//   late NetworkSuccess<List<CartItemEntity>> tSuccessGetItemsResponseQ0;
//
//   setUp(() {
//     mockAddItemToCartUseCase = MockAddItemToCartUseCase();
//     mockRemoveItemFromCartUseCase = MockRemoveItemFromCartUseCase();
//     mockGetCartItemsUseCase = MockGetCartItemsUseCase();
//     mockUpdateItemQuantityUseCase = MockUpdateItemQuantityUseCase();
//     sut = CartCubit(
//       mockAddItemToCartUseCase,
//       mockRemoveItemFromCartUseCase,
//       mockGetCartItemsUseCase,
//       mockUpdateItemQuantityUseCase,
//     );
//     tCartItemEntity = CartItemEntity(fruitEntity: tMockFruit, quantity: 2);
//
//     when(() => tMockFruit.code).thenReturn(tProductId);
//     when(() => tMockFruit.price).thenReturn(10.0);
//
//     tInitialItem = CartItemEntity(
//       fruitEntity: tMockFruit,
//       quantity: tInitialQuantity,
//     );
//     tInitialState = CartSuccess(
//       items: [tInitialItem],
//       totalItemCount: 1,
//       totalPrice: 20.0,
//     );
//
//     tUpdatedItem = CartItemEntity(
//       fruitEntity: tMockFruit,
//       quantity: tNewQuantity,
//     );
//     tUpdatedList = [tUpdatedItem];
//     tSuccessGetItemsResponse = NetworkSuccess<List<CartItemEntity>>(
//       tUpdatedList,
//     );
//
//     tUpdatedItemDec = CartItemEntity(fruitEntity: tMockFruit, quantity: 1);
//     tUpdatedListDec = [tUpdatedItemDec];
//     tSuccessGetItemsResponseDec = NetworkSuccess<List<CartItemEntity>>(
//       tUpdatedListDec,
//     );
//
//     tInitialItemQ1 = CartItemEntity(fruitEntity: tMockFruit, quantity: 1);
//     tInitialStateQ1 = CartSuccess(
//       items: [tInitialItemQ1],
//       totalItemCount: 1,
//       totalPrice: 10.0,
//     );
//     tSuccessGetItemsResponseQ0 = NetworkSuccess<List<CartItemEntity>>(
//       tUpdatedListQ0,
//     );
//   });
//
//   group('cart cubit', () {
//     test('initial state should be CartInitial', () {
//       expect(sut.state, isA<CartInitial>());
//     });
//
//     group('addItemToCart', () {
//       blocTest<CartCubit, CartState>(
//         'emits [CartSuccess] when addItemToCart and subsequent getCartItems are successful',
//         build: () => sut,
//         setUp: () {
//           when(
//             () => mockAddItemToCartUseCase.call(tCartItemEntity),
//           ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
//           when(
//             () => mockGetCartItemsUseCase.call(),
//           ).thenAnswer((_) async => tSuccessResponse);
//         },
//         act: (cubit) => cubit.addItemToCart(tCartItemEntity),
//         expect: () => [
//           isA<CartSuccess>()
//               .having((state) => state.items, 'items', tCartItems)
//               .having((state) => state.totalItemCount, 'totalItemCount', 3)
//               .having((state) => state.totalPrice, 'totalPrice', 47),
//         ],
//         verify: (_) {
//           verifyInOrder([
//             () => mockAddItemToCartUseCase.call(tCartItemEntity),
//             () => mockGetCartItemsUseCase.call(),
//           ]);
//           verifyNoMoreInteractions(mockAddItemToCartUseCase);
//           verifyNoMoreInteractions(mockGetCartItemsUseCase);
//         },
//       );
//
//       blocTest<CartCubit, CartState>(
//         'emits [CartFailure] when addItemToCart fails',
//         build: () => sut,
//         setUp: () {
//           when(
//             () => mockAddItemToCartUseCase.call(tCartItemEntity),
//           ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
//         },
//         act: (cubit) => cubit.addItemToCart(tCartItemEntity),
//         expect: () => [
//           isA<CartFailure>().having(
//             (state) => state.errorMessage,
//             'exception',
//             equals(getErrorMessage(tFailureResponse)),
//           ),
//         ],
//         verify: (_) {
//           verify(
//             () => mockAddItemToCartUseCase.call(tCartItemEntity),
//           ).called(1);
//           verifyNoMoreInteractions(mockAddItemToCartUseCase);
//         },
//       );
//     });
//
//     group('removeItemFromCart', () {
//       blocTest<CartCubit, CartState>(
//         'emits [CartSuccess] when removeItemFromCart and subsequent getCartItems are successful',
//         build: () => sut,
//         setUp: () {
//           when(
//             () => mockRemoveItemFromCartUseCase.call(tProductId),
//           ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
//           when(
//             () => mockGetCartItemsUseCase.call(),
//           ).thenAnswer((_) async => tSuccessResponse);
//         },
//         act: (cubit) => cubit.removeItemFromCart(tProductId),
//         expect: () => [
//           isA<CartSuccess>().having(
//             (state) => state.items,
//             'items',
//             tCartItems,
//           ),
//         ],
//         verify: (_) {
//           verifyInOrder([
//             () => mockRemoveItemFromCartUseCase.call(tProductId),
//             () => mockGetCartItemsUseCase.call(),
//           ]);
//           verifyNoMoreInteractions(mockRemoveItemFromCartUseCase);
//           verifyNoMoreInteractions(mockGetCartItemsUseCase);
//         },
//       );
//
//       blocTest<CartCubit, CartState>(
//         'emits [CartFailure] when removeItemFromCart fails',
//         build: () => sut,
//         setUp: () {
//           when(
//             () => mockRemoveItemFromCartUseCase.call(tProductId),
//           ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
//         },
//         act: (cubit) => cubit.removeItemFromCart(tProductId),
//         expect: () => [
//           isA<CartFailure>().having(
//             (state) => state.errorMessage,
//             'exception',
//             equals(getErrorMessage(tFailureResponse)),
//           ),
//         ],
//         verify: (_) {
//           verify(
//             () => mockRemoveItemFromCartUseCase.call(tProductId),
//           ).called(1);
//           verifyNoMoreInteractions(mockRemoveItemFromCartUseCase);
//         },
//       );
//     });
//
//     group('getCartItems', () {
//       blocTest<CartCubit, CartState>(
//         'emits [CartLoading, CartSuccess] when getCartItems is successful',
//         build: () => sut,
//         setUp: () {
//           when(
//             () => mockGetCartItemsUseCase.call(),
//           ).thenAnswer((_) async => tSuccessResponse);
//         },
//         act: (cubit) => cubit.getCartItems(),
//         expect: () => [
//           isA<CartLoading>(),
//           isA<CartSuccess>()
//               .having((state) => state.items, 'items', tCartItems)
//               .having((state) => state.totalItemCount, 'totalItemCount', 3)
//               .having((state) => state.totalPrice, 'totalPrice', 47),
//         ],
//         verify: (_) {
//           verify(() => mockGetCartItemsUseCase.call()).called(1);
//           verifyNoMoreInteractions(mockGetCartItemsUseCase);
//         },
//       );
//
//       blocTest<CartCubit, CartState>(
//         'emits [CartLoading, CartFailure] when getCartItems fails',
//         build: () => sut,
//         setUp: () {
//           when(
//             () => mockGetCartItemsUseCase.call(),
//           ).thenAnswer((_) async => tFailureResponse);
//         },
//         act: (cubit) => cubit.getCartItems(),
//         expect: () => [
//           isA<CartLoading>(),
//           isA<CartFailure>().having(
//             (state) => state.errorMessage,
//             'exception',
//             equals(getErrorMessage(tFailureResponse)),
//           ),
//         ],
//         verify: (_) {
//           verify(() => mockGetCartItemsUseCase.call()).called(1);
//           verifyNoMoreInteractions(mockGetCartItemsUseCase);
//         },
//       );
//     });
//
//     group('incrementItemQuantity', () {
//       blocTest<CartCubit, CartState>(
//         'emits [CartSuccess] when update and get are successful',
//         build: () => sut,
//         seed: () => tInitialState,
//         setUp: () {
//           when(
//             () => mockUpdateItemQuantityUseCase.call(
//               productId: tProductId,
//               newQuantity: tNewQuantity,
//             ),
//           ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
//           when(
//             () => mockGetCartItemsUseCase.call(),
//           ).thenAnswer((_) async => tSuccessGetItemsResponse);
//         },
//         act: (cubit) => cubit.incrementItemQuantity(tProductId),
//         expect: () => [
//           isA<CartSuccess>()
//               .having((state) => state.items, 'items', tUpdatedList)
//               .having((state) => state.totalPrice, 'totalPrice', 30.0),
//         ],
//         verify: (_) {
//           verifyInOrder([
//             () => mockUpdateItemQuantityUseCase.call(
//               productId: tProductId,
//               newQuantity: tNewQuantity,
//             ),
//             () => mockGetCartItemsUseCase.call(),
//           ]);
//           verifyNoMoreInteractions(mockUpdateItemQuantityUseCase);
//           verifyNoMoreInteractions(mockGetCartItemsUseCase);
//         },
//       );
//
//       blocTest<CartCubit, CartState>(
//         'emits [CartFailure] when update fails',
//         build: () => sut,
//         seed: () => tInitialState,
//         setUp: () {
//           when(
//             () => mockUpdateItemQuantityUseCase.call(
//               productId: tProductId,
//               newQuantity: tNewQuantity,
//             ),
//           ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
//         },
//         act: (cubit) => cubit.incrementItemQuantity(tProductId),
//         expect: () => [
//           isA<CartFailure>().having(
//             (state) => state.errorMessage,
//             'exception',
//             equals(getErrorMessage(tFailureResponse)),
//           ),
//         ],
//         verify: (_) {
//           verify(
//             () => mockUpdateItemQuantityUseCase.call(
//               productId: tProductId,
//               newQuantity: tNewQuantity,
//             ),
//           ).called(1);
//           verifyNoMoreInteractions(mockUpdateItemQuantityUseCase);
//         },
//       );
//       blocTest<CartCubit, CartState>(
//         'emits [] (nothing) when state is not CartSuccess',
//         build: () => sut,
//         act: (cubit) => cubit.incrementItemQuantity(tProductId),
//         expect: () => [],
//         verify: (_) {
//           verifyNever(
//             () => mockUpdateItemQuantityUseCase.call(
//               productId: tProductId,
//               newQuantity: tNewQuantity,
//             ),
//           );
//           verifyNever(() => mockGetCartItemsUseCase.call());
//         },
//       );
//     });
//
//     group('decrementItemQuantity', () {
//       blocTest<CartCubit, CartState>(
//         'emits [CartSuccess] when update (Q=2 -> Q=1) and get are successful',
//         build: () => sut,
//         seed: () => tInitialState,
//         setUp: () {
//           when(
//             () => mockUpdateItemQuantityUseCase.call(
//               productId: tProductId,
//               newQuantity: tNewQuantityDec,
//             ),
//           ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
//           when(
//             () => mockGetCartItemsUseCase.call(),
//           ).thenAnswer((_) async => tSuccessGetItemsResponseDec);
//         },
//         act: (cubit) => cubit.decrementItemQuantity(tProductId),
//         expect: () => [
//           isA<CartSuccess>()
//               .having((state) => state.items, 'items', tUpdatedListDec)
//               .having((state) => state.totalPrice, 'totalPrice', 10.0),
//         ],
//         verify: (_) {
//           verifyInOrder([
//             () => mockUpdateItemQuantityUseCase.call(
//               productId: tProductId,
//               newQuantity: tNewQuantityDec,
//             ),
//             () => mockGetCartItemsUseCase.call(),
//           ]);
//           verifyNoMoreInteractions(mockUpdateItemQuantityUseCase);
//           verifyNoMoreInteractions(mockGetCartItemsUseCase);
//         },
//       );
//
//       blocTest<CartCubit, CartState>(
//         'emits [CartSuccess] when quantity becomes 0 (Q=1 -> Q=0) and remove/get are successful',
//         seed: () => tInitialStateQ1,
//         build: () => sut,
//         setUp: () {
//           when(
//             () => mockRemoveItemFromCartUseCase.call(tProductId),
//           ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
//           when(
//             () => mockGetCartItemsUseCase.call(),
//           ).thenAnswer((_) async => tSuccessGetItemsResponseQ0);
//         },
//         act: (cubit) => cubit.decrementItemQuantity(tProductId),
//         expect: () => [
//           isA<CartSuccess>()
//               .having((state) => state.items, 'items', tUpdatedListQ0)
//               .having((state) => state.totalItemCount, 'totalItemCount', 0),
//         ],
//         verify: (_) {
//           verifyNever(
//             () => mockUpdateItemQuantityUseCase.call(
//               productId: any(named: 'productId'),
//               newQuantity: any(named: 'newQuantity'),
//             ),
//           );
//           verifyInOrder([
//             () => mockRemoveItemFromCartUseCase.call(tProductId),
//             () => mockGetCartItemsUseCase.call(),
//           ]);
//           verifyNoMoreInteractions(mockRemoveItemFromCartUseCase);
//           verifyNoMoreInteractions(mockGetCartItemsUseCase);
//           verifyNoMoreInteractions(mockUpdateItemQuantityUseCase);
//         },
//       );
//
//
//       blocTest(
//         'emits [CartFailure] when update fails',
//         seed: () => tInitialState,
//         build: () => sut,
//         setUp: () {
//           when(
//             () => mockUpdateItemQuantityUseCase.call(
//               productId: tProductId,
//               newQuantity: tNewQuantityDec,
//             ),
//           ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
//         },
//         act: (cubit) => cubit.decrementItemQuantity(tProductId),
//         expect: () => [
//           isA<CartFailure>().having(
//             (state) => state.errorMessage,
//             'exception',
//             equals(getErrorMessage(tFailureResponse)),
//           ),
//         ],
//         verify: (_) {
//           verify(
//             () => mockUpdateItemQuantityUseCase.call(
//               productId: tProductId,
//               newQuantity: tNewQuantityDec,
//             ),
//           ).called(1);
//           verifyNoMoreInteractions(mockUpdateItemQuantityUseCase);
//         },
//       );
//
//       blocTest<CartCubit, CartState>(
//         'emits [] (nothing) when state is not CartSuccess',
//         build: () => sut,
//         act: (cubit) => cubit.decrementItemQuantity(tProductId),
//         expect: () => [],
//         verify: (_) {
//           verifyZeroInteractions(mockUpdateItemQuantityUseCase);
//           verifyZeroInteractions(mockRemoveItemFromCartUseCase);
//           verifyZeroInteractions(mockGetCartItemsUseCase);
//         },
//       );
//     });
//   });
// }
