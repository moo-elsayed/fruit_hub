import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/cart/data/data_sources/cart_remote_data_source.dart';
import 'package:fruit_hub/features/cart/data/repo_imp/cart_repo_imp.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRemoteDataSource extends Mock implements CartRemoteDataSource {}

class MockFruitEntity extends Mock implements FruitEntity {}

void main() {
  late CartRepoImp sut;
  late MockCartRemoteDataSource mockCartRemoteDataSource;
  late MockFruitEntity tFruitEntity;
  late CartItemEntity tCartItemEntity;
  const tProductId = 'product_id';
  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockCartRemoteDataSource = MockCartRemoteDataSource();
    sut = CartRepoImp(mockCartRemoteDataSource);
    tFruitEntity = MockFruitEntity();
    tCartItemEntity = CartItemEntity(fruitEntity: tFruitEntity, quantity: 2);
  });

  group('CartRepoImp', () {
    group('addItemToCart', () {
      test(
        'should call addItemToCart from remote data source with correct params when success response',
        () async {
          // Arrange
          when(
            () => mockCartRemoteDataSource.addItemToCart(tCartItemEntity),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
          // Act
          var result = await sut.addItemToCart(tCartItemEntity);
          // Assert
          expect(result, tSuccessResponseOfTypeVoid);
          verify(
            () => mockCartRemoteDataSource.addItemToCart(tCartItemEntity),
          ).called(1);
          verifyNoMoreInteractions(mockCartRemoteDataSource);
        },
      );

      test(
        'should return failure when addItemToCart from remote data source returns failure response',
        () async {
          // Arrange
          when(
            () => mockCartRemoteDataSource.addItemToCart(tCartItemEntity),
          ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
          // Act
          var result = await sut.addItemToCart(tCartItemEntity);
          // Assert
          expect(result, tFailureResponseOfTypeVoid);
          expect(getErrorMessage(result), "permission-denied");
          verify(
            () => mockCartRemoteDataSource.addItemToCart(tCartItemEntity),
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
  });
}
