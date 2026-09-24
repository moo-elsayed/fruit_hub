import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/home/domain/use_cases/get_best_seller_products_use_case.dart';
import 'package:fruit_hub/features/home/presentation/managers/home_cubit/home_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGetBestSellerProductsUseCase extends Mock
    implements GetBestSellerProductsUseCase {}

void main() {
  late MockGetBestSellerProductsUseCase mockGetBestSellerProductsUseCase;
  late HomeCubit sut;

  const tFruit1 = FruitEntity(
    name: 'تفاح أحمر',
    description: 'تفاح أحمر طازج',
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

  const tFruit2 = FruitEntity(
    name: 'موز بلدي',
    description: 'موز طازج ومغذي',
    price: 15.0,
    imagePath: 'assets/images/banana.png',
    code: 'BANANA_01',
    isFeatured: false,
    avgRating: 4.0,
    ratingCount: 8,
    isOrganic: true,
    daysUntilExpiration: 5,
    weightInGrams: 1000,
    numberOfCalories: 89,
    reviews: [],
  );

  const tUpdatedFruit1 = FruitEntity(
    name: 'تفاح أحمر سوبر',
    description: 'تفاح أحمر طازج ممتاز',
    price: 30.0,
    imagePath: 'assets/images/apple_red.png',
    code: 'APPLE_01',
    isFeatured: true,
    avgRating: 5.0,
    ratingCount: 20,
    isOrganic: true,
    daysUntilExpiration: 8,
    weightInGrams: 500,
    numberOfCalories: 52,
    reviews: [],
  );

  const tErrorMessage = 'فشل في جلب المنتجات الأكثر مبيعاً';
  const tServerFailure = ServerFailure(error: tErrorMessage);

  setUp(() {
    mockGetBestSellerProductsUseCase = MockGetBestSellerProductsUseCase();
    sut = HomeCubit(mockGetBestSellerProductsUseCase);
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be HomeInitial', () {
    // Assert
    expect(sut.state, isA<HomeInitial>());
  });

  group('getBestSellerProducts', () {
    blocTest<HomeCubit, HomeState>(
      'should emit [GetBestSellerProductsLoading, GetBestSellerProductsSuccess] when use case returns NetworkSuccess',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockGetBestSellerProductsUseCase.call())
            .thenAnswer((_) async => const NetworkSuccess([tFruit1, tFruit2]));
      },
      act: (cubit) async => await cubit.getBestSellerProducts(),
      expect: () => [
        isA<GetBestSellerProductsLoading>(),
        isA<GetBestSellerProductsSuccess>().having(
          (state) => state.fruits,
          'fruits',
          [tFruit1, tFruit2],
        ),
      ],
      verify: (_) {
        // Assert
        verify(() => mockGetBestSellerProductsUseCase.call()).called(1);
        verifyNoMoreInteractions(mockGetBestSellerProductsUseCase);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'should emit [GetBestSellerProductsLoading, GetBestSellerProductsSuccess] with empty list when use case returns NetworkSuccess with null data',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockGetBestSellerProductsUseCase.call())
            .thenAnswer((_) async => const NetworkSuccess(null));
      },
      act: (cubit) async => await cubit.getBestSellerProducts(),
      expect: () => [
        isA<GetBestSellerProductsLoading>(),
        isA<GetBestSellerProductsSuccess>().having(
          (state) => state.fruits,
          'fruits',
          isEmpty,
        ),
      ],
      verify: (_) {
        // Assert
        verify(() => mockGetBestSellerProductsUseCase.call()).called(1);
        verifyNoMoreInteractions(mockGetBestSellerProductsUseCase);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'should emit [GetBestSellerProductsLoading, GetBestSellerProductsFailure] when use case returns NetworkFailure',
      build: () => sut,
      setUp: () {
        // Arrange
        when(() => mockGetBestSellerProductsUseCase.call())
            .thenAnswer((_) async => const NetworkFailure(tServerFailure));
      },
      act: (cubit) async => await cubit.getBestSellerProducts(),
      expect: () => [
        isA<GetBestSellerProductsLoading>(),
        isA<GetBestSellerProductsFailure>().having(
          (state) => state.error,
          'error',
          tErrorMessage,
        ),
      ],
      verify: (_) {
        // Assert
        verify(() => mockGetBestSellerProductsUseCase.call()).called(1);
        verifyNoMoreInteractions(mockGetBestSellerProductsUseCase);
      },
    );
  });

  group('updateProduct', () {
    blocTest<HomeCubit, HomeState>(
      'should emit updated GetBestSellerProductsSuccess with modified product when product exists in list',
      build: () => sut,
      setUp: () async {
        // Arrange
        when(() => mockGetBestSellerProductsUseCase.call())
            .thenAnswer((_) async => const NetworkSuccess([tFruit1, tFruit2]));
        await sut.getBestSellerProducts();
      },
      act: (cubit) => cubit.updateProduct(tUpdatedFruit1),
      expect: () => [
        isA<GetBestSellerProductsSuccess>()
            .having((s) => s.fruits.length, 'length', 2)
            .having(
              (s) => s.fruits[0].name,
              'updated product name',
              'تفاح أحمر سوبر',
            )
            .having((s) => s.fruits[0].price, 'updated product price', 30.0)
            .having(
              (s) => s.fruits[1].name,
              'second product unmodified',
              'موز بلدي',
            ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'should not emit any new state when updated product does not exist in list',
      build: () => sut,
      setUp: () async {
        // Arrange
        when(() => mockGetBestSellerProductsUseCase.call())
            .thenAnswer((_) async => const NetworkSuccess([tFruit1, tFruit2]));
        await sut.getBestSellerProducts();
      },
      act: (cubit) =>
          cubit.updateProduct(const FruitEntity(code: 'NON_EXISTING_CODE')),
      expect: () => [],
    );

    blocTest<HomeCubit, HomeState>(
      'should not emit any new state when state is not GetBestSellerProductsSuccess',
      build: () => sut,
      // Current state is HomeInitial
      act: (cubit) => cubit.updateProduct(tUpdatedFruit1),
      expect: () => [],
    );
  });
}
