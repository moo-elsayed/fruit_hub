import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/cart/data/data_sources/remote/cart_remote_data_source.dart';
import 'package:fruit_hub/features/cart/data/repo_imp/cart_repo_imp.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRemoteDataSource extends Mock implements CartRemoteDataSource {}

void main() {
  late CartRepoImp sut;
  late MockCartRemoteDataSource mockCartRemoteDataSource;
  const tProductId = 'product_id';
  const tNewQuantity = 5;
  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(
    Exception("permission-denied"),
  );

  List<CartItemEntity> tCartItems = [
    const CartItemEntity(fruitEntity: FruitEntity(), quantity: 2),
    const CartItemEntity(fruitEntity: FruitEntity(), quantity: 3),
    const CartItemEntity(fruitEntity: FruitEntity(), quantity: 4),
  ];

  final tSuccessResponse = NetworkSuccess<List<CartItemEntity>>(tCartItems);
  final tFailureResponse = NetworkFailure<List<CartItemEntity>>(
    Exception("permission-denied"),
  );

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

  setUp(() {
    mockCartRemoteDataSource = MockCartRemoteDataSource();
    sut = CartRepoImp(mockCartRemoteDataSource);
  });

  group('CartRepoImp', () {
    group('addItemToCart', () {
      test(
        'should call addItemToCart from remote data source with correct params when success response',
        () async {
          // Arrange
          when(
            () => mockCartRemoteDataSource.addItemToCart(tProductId),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
          // Act
          var result = await sut.addItemToCart(tProductId);
          // Assert
          expect(result, tSuccessResponseOfTypeVoid);
          verify(
            () => mockCartRemoteDataSource.addItemToCart(tProductId),
          ).called(1);
          verifyNoMoreInteractions(mockCartRemoteDataSource);
        },
      );

      test(
        'should return failure when addItemToCart from remote data source returns failure response',
        () async {
          // Arrange
          when(
            () => mockCartRemoteDataSource.addItemToCart(tProductId),
          ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
          // Act
          var result = await sut.addItemToCart(tProductId);
          // Assert
          expect(result, tFailureResponseOfTypeVoid);
          expect(getErrorMessage(result), "permission-denied");
          verify(
            () => mockCartRemoteDataSource.addItemToCart(tProductId),
          ).called(1);
          verifyNoMoreInteractions(mockCartRemoteDataSource);
        },
      );
    });

    group('removeItemFromCart', () {
      test(
        'should call removeItemFromCart from remote data source with correct params when success response',
        () async {
          // Arrange
          when(
            () => mockCartRemoteDataSource.removeItemFromCart(tProductId),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
          // Act
          var result = await sut.removeItemFromCart(tProductId);
          // Assert
          expect(result, tSuccessResponseOfTypeVoid);
          verify(
            () => mockCartRemoteDataSource.removeItemFromCart(tProductId),
          ).called(1);
          verifyNoMoreInteractions(mockCartRemoteDataSource);
        },
      );

      test(
        'should return failure when removeItemFromCart from remote data source returns failure response',
        () async {
          // Arrange
          when(
            () => mockCartRemoteDataSource.removeItemFromCart(tProductId),
          ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
          // Act
          var result = await sut.removeItemFromCart(tProductId);
          // Assert
          expect(result, tFailureResponseOfTypeVoid);
          expect(getErrorMessage(result), "permission-denied");
          verify(
            () => mockCartRemoteDataSource.removeItemFromCart(tProductId),
          ).called(1);
          verifyNoMoreInteractions(mockCartRemoteDataSource);
        },
      );
    });
    group('getCartItems', () {
      test(
        'should call getCartItems from remote data source with correct params when success response',
        () async {
          // Arrange
          when(
            () => mockCartRemoteDataSource.getCartItems(),
          ).thenAnswer((_) async => tSuccessResponseOfTypeListMapStringDynamic);
          // Act
          var result = await sut.getCartItems();
          // Assert
          expect(result, tSuccessResponseOfTypeListMapStringDynamic);
          verify(() => mockCartRemoteDataSource.getCartItems()).called(1);
          verifyNoMoreInteractions(mockCartRemoteDataSource);
        },
      );

      test(
        'should return failure when getCartItems from remote data source returns failure response',
        () async {
          // Arrange
          when(
            () => mockCartRemoteDataSource.getCartItems(),
          ).thenAnswer((_) async => tFailureResponseOfTypeListMapStringDynamic);
          // Act
          var result = await sut.getCartItems();
          // Assert
          expect(result, tFailureResponseOfTypeListMapStringDynamic);
          expect(getErrorMessage(result), "permission-denied");
          verify(() => mockCartRemoteDataSource.getCartItems()).called(1);
          verifyNoMoreInteractions(mockCartRemoteDataSource);
        },
      );
    });

    group('updateItemQuantity', () {
      test(
        'should call updateItemQuantity from remote data source with correct params when success response',
        () async {
          // Arrange
          when(
            () => mockCartRemoteDataSource.updateItemQuantity(
              newQuantity: tNewQuantity,
              productId: tProductId,
            ),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
          // Act
          var result = await sut.updateItemQuantity(
            newQuantity: tNewQuantity,
            productId: tProductId,
          );
          // Assert
          expect(result, tSuccessResponseOfTypeVoid);
          verify(
            () => mockCartRemoteDataSource.updateItemQuantity(
              newQuantity: tNewQuantity,
              productId: tProductId,
            ),
          ).called(1);
          verifyNoMoreInteractions(mockCartRemoteDataSource);
        },
      );

      test(
        'should return failure when updateItemQuantity from remote data source returns failure response',
        () async {
          // Arrange
          when(
            () => mockCartRemoteDataSource.updateItemQuantity(
              newQuantity: tNewQuantity,
              productId: tProductId,
            ),
          ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
          // Act
          var result = await sut.updateItemQuantity(
            newQuantity: tNewQuantity,
            productId: tProductId,
          );
          // Assert
          expect(result, tFailureResponseOfTypeVoid);
          expect(getErrorMessage(result), "permission-denied");
          verify(
            () => mockCartRemoteDataSource.updateItemQuantity(
              newQuantity: tNewQuantity,
              productId: tProductId,
            ),
          ).called(1);
          verifyNoMoreInteractions(mockCartRemoteDataSource);
        },
      );
    });

    group('getProductsInCart', () {
      test(
        'should call getProductsInCart from remote data source with correct params when success response',
        () async {
          // Arrange
          when(
            () => mockCartRemoteDataSource.getProductsInCart(cartItems),
          ).thenAnswer((_) async => tSuccessResponse);
          // Act
          var result = await sut.getProductsInCart(cartItems);
          // Assert
          expect(result, tSuccessResponse);
          verify(
            () => mockCartRemoteDataSource.getProductsInCart(cartItems),
          ).called(1);
          verifyNoMoreInteractions(mockCartRemoteDataSource);
        },
      );

      test(
        'should return failure when getProductsInCart from remote data source returns failure response',
        () async {
          // Arrange
          when(
            () => mockCartRemoteDataSource.getProductsInCart(cartItems),
          ).thenAnswer((_) async => tFailureResponse);
          // Act
          var result = await sut.getProductsInCart(cartItems);
          // Assert
          expect(result, tFailureResponse);
          expect(getErrorMessage(result), "permission-denied");
          verify(
            () => mockCartRemoteDataSource.getProductsInCart(cartItems),
          ).called(1);
          verifyNoMoreInteractions(mockCartRemoteDataSource);
        },
      );
    });
  });
}
