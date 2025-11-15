import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
import 'package:mocktail/mocktail.dart';
import '../../data/data_sources/cart_remote_data_source_imp_test.dart';

class MockCartRepo extends Mock implements CartRepo {}

void main() {
  late AddItemToCartUseCase sut;
  late MockCartRepo mockCartRepo;
  late MockFruitEntity tFruitEntity;
  late CartItemEntity tCartItemEntity;
  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockCartRepo = MockCartRepo();
    sut = AddItemToCartUseCase(mockCartRepo);
    tFruitEntity = MockFruitEntity();
    tCartItemEntity = CartItemEntity(fruitEntity: tFruitEntity, quantity: 2);
  });

  group('addItemToCartUseCase', () {
    test(
      'should call addItemToCartUseCase from repo with correct params when called with correct params',
      () async {
        // Arrange
        when(
          () => mockCartRepo.addItemToCart(tCartItemEntity),
        ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
        // Act
        var result = await sut.call(tCartItemEntity);
        // Assert
        expect(result, tSuccessResponseOfTypeVoid);
        verify(() => mockCartRepo.addItemToCart(tCartItemEntity)).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );

    test(
      'should return failure when addItemToCartUseCase from repo fails',
      () async {
        // Arrange
        when(
          () => mockCartRepo.addItemToCart(tCartItemEntity),
        ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
        // Act
        var result = await sut.call(tCartItemEntity);
        // Assert
        expect(result, tFailureResponseOfTypeVoid);
        verify(() => mockCartRepo.addItemToCart(tCartItemEntity)).called(1);
        verifyNoMoreInteractions(mockCartRepo);
      },
    );
  });
}
