import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/enums/product_category_filter.dart';
import 'package:fruit_hub/core/enums/product_sort_type.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/products/domain/entities/paginated_products_entity.dart';
import 'package:fruit_hub/features/products/domain/entities/products_filter_entity.dart';
import 'package:fruit_hub/features/products/domain/use_cases/get_all_products_use_case.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllProductsUseCase extends Mock implements GetAllProductsUseCase {}

class FakeProductsFilterEntity extends Fake implements ProductsFilterEntity {}

void main() {
  late MockGetAllProductsUseCase mockGetAllProductsUseCase;
  late ProductsCubit sut;

  setUpAll(() {
    registerFallbackValue(FakeProductsFilterEntity());
  });

  const tFruit1 = FruitEntity(
    name: 'تفاح أحمر',
    description: 'تفاح أحمر طازج ولذيذ',
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

  const tPaginatedProductsPage1 = PaginatedProductsEntity(
    fruits: [tFruit1],
    lastDoc: 'doc_1',
    hasMore: true,
  );

  const tPaginatedProductsPage2 = PaginatedProductsEntity(
    fruits: [tFruit2],
    lastDoc: 'doc_2',
    hasMore: false,
  );

  const tErrorMessage = 'فشل في جلب المنتجات';
  const tServerFailure = ServerFailure(error: tErrorMessage);

  setUp(() {
    mockGetAllProductsUseCase = MockGetAllProductsUseCase();
    sut = ProductsCubit(getAllProductsUseCase: mockGetAllProductsUseCase);
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be ProductsInitial', () {
    // Assert
    expect(sut.state, isA<ProductsInitial>());
    expect(sut.hasMore, isTrue);
    expect(sut.isLoadingMore, isFalse);
  });

  group('fetchFirstPage', () {
    blocTest<ProductsCubit, ProductsState>(
      'should emit [GetProductsLoading, GetProductsSuccess] when use case returns NetworkSuccess',
      build: () => sut,
      setUp: () {
        // Arrange
        when(
          () => mockGetAllProductsUseCase.call(
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            lastDoc: any(named: 'lastDoc'),
          ),
        ).thenAnswer(
          (_) async => const NetworkSuccess(tPaginatedProductsPage1),
        );
      },
      act: (cubit) async => await cubit.fetchFirstPage(),
      expect: () => [
        isA<GetProductsLoading>(),
        isA<GetProductsSuccess>()
            .having((state) => state.fruits, 'fruits', [tFruit1])
            .having((state) => state.hasMore, 'hasMore', isTrue)
            .having((state) => state.isLoadingMore, 'isLoadingMore', isFalse),
      ],
      verify: (_) {
        // Assert
        verify(
          () => mockGetAllProductsUseCase.call(
            limit: 10,
            filter: const ProductsFilterEntity(),
          ),
        ).called(1);
      },
    );

    blocTest<ProductsCubit, ProductsState>(
      'should emit [GetProductsLoading, GetProductsFailure] when use case returns NetworkFailure',
      build: () => sut,
      setUp: () {
        // Arrange
        when(
          () => mockGetAllProductsUseCase.call(
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            lastDoc: any(named: 'lastDoc'),
          ),
        ).thenAnswer((_) async => const NetworkFailure(tServerFailure));
      },
      act: (cubit) async => await cubit.fetchFirstPage(),
      expect: () => [
        isA<GetProductsLoading>(),
        isA<GetProductsFailure>().having(
          (state) => state.error,
          'error',
          tErrorMessage,
        ),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'should update currentFilter when filter parameter is passed',
      build: () => sut,
      setUp: () {
        // Arrange
        when(
          () => mockGetAllProductsUseCase.call(
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            lastDoc: any(named: 'lastDoc'),
          ),
        ).thenAnswer(
          (_) async => const NetworkSuccess(tPaginatedProductsPage1),
        );
      },
      act: (cubit) async => await cubit.fetchFirstPage(
        filter: const ProductsFilterEntity(
          categoryFilter: ProductCategoryFilter.organic,
        ),
      ),
      expect: () => [
        isA<GetProductsLoading>(),
        isA<GetProductsSuccess>().having(
          (state) => state.filter.categoryFilter,
          'categoryFilter',
          ProductCategoryFilter.organic,
        ),
      ],
    );
  });

  group('fetchNextPage', () {
    blocTest<ProductsCubit, ProductsState>(
      'should not call use case or emit states when state is not GetProductsSuccess',
      build: () => sut,
      act: (cubit) async => await cubit.fetchNextPage(),
      expect: () => [],
      verify: (_) {
        verifyZeroInteractions(mockGetAllProductsUseCase);
      },
    );

    blocTest<ProductsCubit, ProductsState>(
      'should not call use case or emit states when hasMore is false',
      build: () => sut,
      setUp: () async {
        when(
          () => mockGetAllProductsUseCase.call(
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            lastDoc: any(named: 'lastDoc'),
          ),
        ).thenAnswer(
          (_) async => const NetworkSuccess(tPaginatedProductsPage2),
        );
        await sut.fetchFirstPage();
      },
      act: (cubit) async => await cubit.fetchNextPage(),
      expect: () => [],
    );

    blocTest<ProductsCubit, ProductsState>(
      'should append new fruits and emit updated GetProductsSuccess when fetchNextPage succeeds',
      build: () => sut,
      setUp: () async {
        when(
          () => mockGetAllProductsUseCase.call(
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            lastDoc: null,
          ),
        ).thenAnswer(
          (_) async => const NetworkSuccess(tPaginatedProductsPage1),
        );

        when(
          () => mockGetAllProductsUseCase.call(
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            lastDoc: 'doc_1',
          ),
        ).thenAnswer(
          (_) async => const NetworkSuccess(tPaginatedProductsPage2),
        );

        await sut.fetchFirstPage();
      },
      act: (cubit) async => await cubit.fetchNextPage(),
      expect: () => [
        isA<GetProductsSuccess>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', isTrue)
            .having((s) => s.fruits, 'fruits', [tFruit1]),
        isA<GetProductsSuccess>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', isFalse)
            .having((s) => s.fruits, 'fruits', [tFruit1, tFruit2])
            .having((s) => s.hasMore, 'hasMore', isFalse),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'should reset isLoadingMore to false when fetchNextPage returns NetworkFailure',
      build: () => sut,
      setUp: () async {
        when(
          () => mockGetAllProductsUseCase.call(
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            lastDoc: null,
          ),
        ).thenAnswer(
          (_) async => const NetworkSuccess(tPaginatedProductsPage1),
        );

        when(
          () => mockGetAllProductsUseCase.call(
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            lastDoc: 'doc_1',
          ),
        ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

        await sut.fetchFirstPage();
      },
      act: (cubit) async => await cubit.fetchNextPage(),
      expect: () => [
        isA<GetProductsSuccess>().having(
          (s) => s.isLoadingMore,
          'isLoadingMore',
          isTrue,
        ),
        isA<GetProductsSuccess>().having(
          (s) => s.isLoadingMore,
          'isLoadingMore',
          isFalse,
        ),
      ],
    );
  });

  group('filtering and reset', () {
    blocTest<ProductsCubit, ProductsState>(
      'applyFilter should update currentFilter and call fetchFirstPage',
      build: () => sut,
      setUp: () {
        when(
          () => mockGetAllProductsUseCase.call(
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            lastDoc: any(named: 'lastDoc'),
          ),
        ).thenAnswer(
          (_) async => const NetworkSuccess(tPaginatedProductsPage1),
        );
      },
      act: (cubit) => cubit.applyFilter(
        const ProductsFilterEntity(
          sortType: ProductSortType.priceLowestToHighest,
        ),
      ),
      expect: () => [
        isA<GetProductsLoading>(),
        isA<GetProductsSuccess>().having(
          (s) => s.filter.sortType,
          'sortType',
          ProductSortType.priceLowestToHighest,
        ),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'setCategoryFilter should not re-fetch if category is already selected',
      build: () => sut,
      act: (cubit) => cubit.setCategoryFilter(ProductCategoryFilter.all),
      expect: () => [],
      verify: (_) {
        verifyZeroInteractions(mockGetAllProductsUseCase);
      },
    );

    blocTest<ProductsCubit, ProductsState>(
      'resetFilter should reset currentFilter to default and fetch first page',
      build: () => sut,
      setUp: () {
        when(
          () => mockGetAllProductsUseCase.call(
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            lastDoc: any(named: 'lastDoc'),
          ),
        ).thenAnswer(
          (_) async => const NetworkSuccess(tPaginatedProductsPage1),
        );
      },
      act: (cubit) {
        cubit.currentFilter = const ProductsFilterEntity(
          categoryFilter: ProductCategoryFilter.organic,
        );
        cubit.resetFilter();
      },
      expect: () => [
        isA<GetProductsLoading>(),
        isA<GetProductsSuccess>().having(
          (s) => s.filter,
          'filter',
          const ProductsFilterEntity(),
        ),
      ],
    );
  });

  group('updateProduct', () {
    const tUpdatedFruit1 = FruitEntity(
      name: 'تفاح أحمر سوبر',
      description: 'تفاح أحمر طازج ولذيذ',
      price: 30.0,
      imagePath: 'assets/images/apple_red.png',
      code: 'APPLE_01',
      isFeatured: true,
      avgRating: 5.0,
      ratingCount: 20,
      isOrganic: true,
      daysUntilExpiration: 10,
      weightInGrams: 500,
      numberOfCalories: 52,
      reviews: [],
    );

    blocTest<ProductsCubit, ProductsState>(
      'should update fruit in list and emit new GetProductsSuccess when fruit exists in list',
      build: () => sut,
      setUp: () async {
        when(
          () => mockGetAllProductsUseCase.call(
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            lastDoc: any(named: 'lastDoc'),
          ),
        ).thenAnswer(
          (_) async => const NetworkSuccess(tPaginatedProductsPage1),
        );
        await sut.fetchFirstPage();
      },
      act: (cubit) => cubit.updateProduct(tUpdatedFruit1),
      expect: () => [
        isA<GetProductsSuccess>().having(
          (s) => s.fruits.first.name,
          'first fruit name',
          'تفاح أحمر سوبر',
        ),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'should not emit state when fruit does not exist in list',
      build: () => sut,
      setUp: () async {
        when(
          () => mockGetAllProductsUseCase.call(
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            lastDoc: any(named: 'lastDoc'),
          ),
        ).thenAnswer(
          (_) async => const NetworkSuccess(tPaginatedProductsPage1),
        );
        await sut.fetchFirstPage();
      },
      act: (cubit) =>
          cubit.updateProduct(const FruitEntity(code: 'NON_EXISTING')),
      expect: () => [],
    );
  });
}
