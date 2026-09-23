import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/products/domain/use_cases/get_product_details_use_case.dart';
import 'package:fruit_hub/features/products/presentation/managers/product_details_cubit/product_details_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProductDetailsUseCase extends Mock
    implements GetProductDetailsUseCase {}

void main() {
  late MockGetProductDetailsUseCase mockGetProductDetailsUseCase;
  late ProductDetailsCubit sut;

  const tCode = 'APPLE_01';
  const tFruit = FruitEntity(
    name: 'تفاح أحمر',
    description: 'تفاح طازج ولذيذ',
    price: 25.0,
    imagePath: 'assets/images/apple_red.png',
    code: 'APPLE_01',
    isFeatured: true,
    avgRating: 4.5,
    ratingCount: 15,
    isOrganic: true,
    daysUntilExpiration: 10,
    weightInGrams: 500,
    numberOfCalories: 52,
    reviews: [],
  );

  const tUpdatedFruit = FruitEntity(
    name: 'تفاح أحمر محدث',
    description: 'تفاح طازج ولذيذ',
    price: 25.0,
    imagePath: 'assets/images/apple_red.png',
    code: 'APPLE_01',
    isFeatured: true,
    avgRating: 5.0,
    ratingCount: 16,
    isOrganic: true,
    daysUntilExpiration: 10,
    weightInGrams: 500,
    numberOfCalories: 52,
    reviews: [],
  );

  const tErrorMessage = 'المنتج غير موجود';
  const tServerFailure = ServerFailure(error: tErrorMessage);

  setUp(() {
    mockGetProductDetailsUseCase = MockGetProductDetailsUseCase();
    sut = ProductDetailsCubit(
      getProductDetailsUseCase: mockGetProductDetailsUseCase,
    );
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be ProductDetailsInitial', () {
    // Assert
    expect(sut.state, isA<ProductDetailsInitial>());
  });

  group('getProductDetails', () {
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      'should emit [ProductDetailsLoading, ProductDetailsSuccess] when use case returns NetworkSuccess',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockGetProductDetailsUseCase(tCode))
            .thenAnswer((_) async => const NetworkSuccess(tFruit));
      },
      act: (cubit) async {
        // Act
        await cubit.getProductDetails(tCode);
      },
      expect: () => [
        isA<ProductDetailsLoading>(),
        isA<ProductDetailsSuccess>().having(
          (state) => state.fruit,
          'fruit',
          tFruit,
        ),
      ],
      verify: (_) {
        // Assert
        verify(() => mockGetProductDetailsUseCase(tCode)).called(1);
        verifyNoMoreInteractions(mockGetProductDetailsUseCase);
      },
    );

    blocTest<ProductDetailsCubit, ProductDetailsState>(
      'should emit [ProductDetailsLoading, ProductDetailsFailure] when use case returns NetworkFailure',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockGetProductDetailsUseCase(tCode))
            .thenAnswer((_) async => const NetworkFailure(tServerFailure));
      },
      act: (cubit) async {
        // Act
        await cubit.getProductDetails(tCode);
      },
      expect: () => [
        isA<ProductDetailsLoading>(),
        isA<ProductDetailsFailure>().having(
          (state) => state.error,
          'error',
          tErrorMessage,
        ),
      ],
      verify: (_) {
        // Assert
        verify(() => mockGetProductDetailsUseCase(tCode)).called(1);
        verifyNoMoreInteractions(mockGetProductDetailsUseCase);
      },
    );
  });

  group('updateProduct', () {
    blocTest<ProductDetailsCubit, ProductDetailsState>(
      'should emit [ProductDetailsSuccess] with updated fruit when updateProduct is called',
      build: () => sut,
      seed: () => ProductDetailsSuccess(tFruit),
      act: (cubit) => cubit.updateProduct(tUpdatedFruit),
      expect: () => [
        isA<ProductDetailsSuccess>().having(
          (state) => state.fruit,
          'fruit',
          tUpdatedFruit,
        ),
      ],
    );
  });
}
