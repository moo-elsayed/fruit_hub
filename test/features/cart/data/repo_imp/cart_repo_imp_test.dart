import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/cart/data/data_sources/remote/cart_remote_data_source.dart';
import 'package:fruit_hub/features/cart/data/repo_imp/cart_repo_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRemoteDataSource extends Mock implements CartRemoteDataSource {}

void main() {
  late MockCartRemoteDataSource mockCartRemoteDataSource;
  late CartRepoImp sut;

  const tProductId = 'APPLE_01';
  const tFailure = ServerFailure(error: 'An unexpected error occurred');

  const tFruit = FruitEntity(
    name: 'تفاح أحمر',
    description: 'تفاح أحمر طازج',
    price: 25.0,
    imagePath: 'assets/images/red_apple.png',
    code: tProductId,
  );

  const tCartItem = CartItemEntity(fruitEntity: tFruit, quantity: 2);

  setUp(() {
    mockCartRemoteDataSource = MockCartRemoteDataSource();
    sut = CartRepoImp(mockCartRemoteDataSource);
  });

  group('addItemToCart', () {
    test(
      'should return NetworkSuccess when remote data source succeeds',
      () async {
        // Arrange
        when(
          () => mockCartRemoteDataSource.addItemToCart(
            tProductId,
            quantity: 3,
          ),
        ).thenAnswer((_) async => const NetworkSuccess(null));

        // Act
        final result = await sut.addItemToCart(tProductId, quantity: 3);

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockCartRemoteDataSource.addItemToCart(
            tProductId,
            quantity: 3,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockCartRemoteDataSource);
      },
    );

    test(
      'should use default quantity of 1 when quantity is not specified',
      () async {
        // Arrange
        when(
          () => mockCartRemoteDataSource.addItemToCart(
            tProductId,
            quantity: 1,
          ),
        ).thenAnswer((_) async => const NetworkSuccess(null));

        // Act
        final result = await sut.addItemToCart(tProductId);

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockCartRemoteDataSource.addItemToCart(
            tProductId,
            quantity: 1,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockCartRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remote data source fails',
      () async {
        // Arrange
        when(
          () => mockCartRemoteDataSource.addItemToCart(
            tProductId,
            quantity: 1,
          ),
        ).thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut.addItemToCart(tProductId);

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure.error, tFailure.error);
        verify(
          () => mockCartRemoteDataSource.addItemToCart(
            tProductId,
            quantity: 1,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockCartRemoteDataSource);
      },
    );
  });

  group('removeItemFromCart', () {
    test(
      'should return NetworkSuccess when remote data source succeeds',
      () async {
        // Arrange
        when(
          () => mockCartRemoteDataSource.removeItemFromCart(tProductId),
        ).thenAnswer((_) async => const NetworkSuccess(null));

        // Act
        final result = await sut.removeItemFromCart(tProductId);

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockCartRemoteDataSource.removeItemFromCart(tProductId),
        ).called(1);
        verifyNoMoreInteractions(mockCartRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remote data source fails',
      () async {
        // Arrange
        when(
          () => mockCartRemoteDataSource.removeItemFromCart(tProductId),
        ).thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut.removeItemFromCart(tProductId);

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure.error, tFailure.error);
        verify(
          () => mockCartRemoteDataSource.removeItemFromCart(tProductId),
        ).called(1);
        verifyNoMoreInteractions(mockCartRemoteDataSource);
      },
    );
  });

  group('getProductsInCart', () {
    test(
      'should return NetworkSuccess with list of CartItemEntity when remote data source succeeds',
      () async {
        // Arrange
        when(
          () => mockCartRemoteDataSource.getProductsInCart(),
        ).thenAnswer((_) async => const NetworkSuccess([tCartItem]));

        // Act
        final result = await sut.getProductsInCart();

        // Assert
        expect(result, isA<NetworkSuccess<List<CartItemEntity>>>());
        final items = (result as NetworkSuccess<List<CartItemEntity>>).data;
        expect(items, hasLength(1));
        expect(items!.first, equals(tCartItem));
        verify(() => mockCartRemoteDataSource.getProductsInCart()).called(1);
        verifyNoMoreInteractions(mockCartRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remote data source fails',
      () async {
        // Arrange
        when(
          () => mockCartRemoteDataSource.getProductsInCart(),
        ).thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut.getProductsInCart();

        // Assert
        expect(result, isA<NetworkFailure<List<CartItemEntity>>>());
        final failure =
            (result as NetworkFailure<List<CartItemEntity>>).failure;
        expect(failure.error, tFailure.error);
        verify(() => mockCartRemoteDataSource.getProductsInCart()).called(1);
        verifyNoMoreInteractions(mockCartRemoteDataSource);
      },
    );
  });

  group('updateItemQuantity', () {
    test(
      'should return NetworkSuccess when remote data source succeeds',
      () async {
        // Arrange
        when(
          () => mockCartRemoteDataSource.updateItemQuantity(
            productId: tProductId,
            newQuantity: 5,
          ),
        ).thenAnswer((_) async => const NetworkSuccess(null));

        // Act
        final result = await sut.updateItemQuantity(
          productId: tProductId,
          newQuantity: 5,
        );

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockCartRemoteDataSource.updateItemQuantity(
            productId: tProductId,
            newQuantity: 5,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockCartRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remote data source fails',
      () async {
        // Arrange
        when(
          () => mockCartRemoteDataSource.updateItemQuantity(
            productId: tProductId,
            newQuantity: 5,
          ),
        ).thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut.updateItemQuantity(
          productId: tProductId,
          newQuantity: 5,
        );

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure.error, tFailure.error);
        verify(
          () => mockCartRemoteDataSource.updateItemQuantity(
            productId: tProductId,
            newQuantity: 5,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockCartRemoteDataSource);
      },
    );
  });

  group('clearCart', () {
    test(
      'should return NetworkSuccess when remote data source succeeds',
      () async {
        // Arrange
        when(
          () => mockCartRemoteDataSource.clearCart(),
        ).thenAnswer((_) async => const NetworkSuccess(null));

        // Act
        final result = await sut.clearCart();

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(() => mockCartRemoteDataSource.clearCart()).called(1);
        verifyNoMoreInteractions(mockCartRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remote data source fails',
      () async {
        // Arrange
        when(
          () => mockCartRemoteDataSource.clearCart(),
        ).thenAnswer((_) async => const NetworkFailure(tFailure));

        // Act
        final result = await sut.clearCart();

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure.error, tFailure.error);
        verify(() => mockCartRemoteDataSource.clearCart()).called(1);
        verifyNoMoreInteractions(mockCartRemoteDataSource);
      },
    );
  });
}
