import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/enums/product_category_filter.dart';
import 'package:fruit_hub/core/enums/product_sort_type.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/products/domain/entities/paginated_products_entity.dart';
import 'package:fruit_hub/features/products/domain/entities/products_filter_entity.dart';
import 'package:fruit_hub/features/products/domain/repo/products_repo.dart';
import 'package:fruit_hub/features/products/domain/use_cases/get_all_products_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsRepo extends Mock implements ProductsRepo {}

class FakeProductsFilterEntity extends Fake implements ProductsFilterEntity {}

void main() {
  late MockProductsRepo mockProductsRepo;
  late GetAllProductsUseCase sut;

  setUpAll(() {
    registerFallbackValue(FakeProductsFilterEntity());
  });

  const tFruitEntity = FruitEntity(
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

  const tPaginatedProductsEntity = PaginatedProductsEntity(
    fruits: [tFruitEntity],
    lastDoc: 'snapshot_123',
    hasMore: true,
  );

  const tServerFailure = ServerFailure(error: 'فشل في جلب المنتجات');

  setUp(() {
    mockProductsRepo = MockProductsRepo();
    sut = GetAllProductsUseCase(mockProductsRepo);
  });

  test('should call getProducts on ProductsRepo with correct parameters and return NetworkSuccess with PaginatedProductsEntity when repo succeeds', () async {
    // Arrange
    const filter = ProductsFilterEntity(
      sortType: ProductSortType.priceLowestToHighest,
      categoryFilter: ProductCategoryFilter.organic,
    );
    const limit = 5;
    const lastDoc = 'doc_snapshot';

    when(
      () => mockProductsRepo.getProducts(
        lastDoc: any(named: 'lastDoc'),
        limit: any(named: 'limit'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer((_) async => const NetworkSuccess(tPaginatedProductsEntity));

    // Act
    final result = await sut(lastDoc: lastDoc, limit: limit, filter: filter);

    // Assert
    expect(result, isA<NetworkSuccess<PaginatedProductsEntity>>());
    final successResult = result as NetworkSuccess<PaginatedProductsEntity>;
    expect(successResult.data, equals(tPaginatedProductsEntity));
    verify(
      () => mockProductsRepo.getProducts(
        lastDoc: lastDoc,
        limit: limit,
        filter: filter,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockProductsRepo);
  });

  test('should call getProducts on ProductsRepo with default parameters when no arguments are passed', () async {
    // Arrange
    when(
      () => mockProductsRepo.getProducts(
        lastDoc: any(named: 'lastDoc'),
        limit: any(named: 'limit'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer((_) async => const NetworkSuccess(tPaginatedProductsEntity));

    // Act
    final result = await sut();

    // Assert
    expect(result, isA<NetworkSuccess<PaginatedProductsEntity>>());
    final successResult = result as NetworkSuccess<PaginatedProductsEntity>;
    expect(successResult.data, equals(tPaginatedProductsEntity));
    verify(
      () =>
          mockProductsRepo.getProducts(lastDoc: null, limit: 10, filter: null),
    ).called(1);
    verifyNoMoreInteractions(mockProductsRepo);
  });

  test(
    'should return NetworkFailure when ProductsRepo fails during getProducts',
    () async {
      // Arrange
      when(
        () => mockProductsRepo.getProducts(
          lastDoc: any(named: 'lastDoc'),
          limit: any(named: 'limit'),
          filter: any(named: 'filter'),
        ),
      ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

      // Act
      final result = await sut();

      // Assert
      expect(result, isA<NetworkFailure<PaginatedProductsEntity>>());
      final failureResult = result as NetworkFailure<PaginatedProductsEntity>;
      expect(failureResult.failure.error, tServerFailure.error);
      verify(
        () => mockProductsRepo.getProducts(
          lastDoc: null,
          limit: 10,
          filter: null,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockProductsRepo);
    },
  );
}
