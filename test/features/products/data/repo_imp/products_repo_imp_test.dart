import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/enums/product_category_filter.dart';
import 'package:fruit_hub/core/enums/product_sort_type.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/models/review_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/products/data/data_sources/remote/products_remote_data_source.dart';
import 'package:fruit_hub/features/products/data/models/paginated_products_data.dart';
import 'package:fruit_hub/features/products/data/models/products_filter_model.dart';
import 'package:fruit_hub/features/products/data/repo_imp/products_repo_imp.dart';
import 'package:fruit_hub/features/products/domain/entities/paginated_products_entity.dart';
import 'package:fruit_hub/features/products/domain/entities/products_filter_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsRemoteDataSource extends Mock
    implements ProductsRemoteDataSource {}

class FakeProductsFilterModel extends Fake implements ProductsFilterModel {}

void main() {
  late MockProductsRemoteDataSource mockProductsRemoteDataSource;
  late ProductsRepoImp sut;

  setUpAll(() {
    registerFallbackValue(FakeProductsFilterModel());
  });

  const tReviewModel = ReviewModel(
    name: 'أحمد',
    image: 'assets/images/user1.png',
    description: 'جودة ممتازة',
    date: '2026-09-01',
    rating: 5.0,
    userId: 'user_1',
  );

  const tReviewEntity = ReviewEntity(
    name: 'أحمد',
    image: 'assets/images/user1.png',
    description: 'جودة ممتازة',
    date: '2026-09-01',
    rating: 5.0,
    userId: 'user_1',
  );

  final tFruitModel1 = FruitModel(
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
    sellingCount: 100,
    reviews: const [tReviewModel],
  );

  final tFruitModel2 = FruitModel(
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
    sellingCount: 200,
    reviews: const [],
  );

  const tFruitEntity1 = FruitEntity(
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
    reviews: [tReviewEntity],
  );

  const tFruitEntity2 = FruitEntity(
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

  final tPaginatedData = PaginatedProductsData(
    fruits: [tFruitModel1, tFruitModel2],
    lastDoc: 'mock_last_doc_snapshot',
    hasMore: true,
  );

  const tPaginatedEntity = PaginatedProductsEntity(
    fruits: [tFruitEntity1, tFruitEntity2],
    lastDoc: 'mock_last_doc_snapshot',
    hasMore: true,
  );

  const tServerFailure = ServerFailure(error: 'فشل في جلب المنتجات');

  setUp(() {
    mockProductsRemoteDataSource = MockProductsRemoteDataSource();
    sut = ProductsRepoImp(mockProductsRemoteDataSource);
  });

  group('getProducts', () {
    test('should call remoteDataSource.getProducts with mapped filter and parameters and return NetworkSuccess with mapped PaginatedProductsEntity when remoteDataSource succeeds', () async {
      // Arrange
      const filterEntity = ProductsFilterEntity(
        sortType: ProductSortType.priceLowestToHighest,
        categoryFilter: ProductCategoryFilter.organic,
      );
      const limit = 5;
      const lastDoc = 'doc_snapshot_1';

      when(
        () => mockProductsRemoteDataSource.getProducts(
          lastDoc: any(named: 'lastDoc'),
          limit: any(named: 'limit'),
          filter: any(named: 'filter'),
        ),
      ).thenAnswer((_) async => NetworkSuccess(tPaginatedData));

      // Act
      final result = await sut.getProducts(
        lastDoc: lastDoc,
        limit: limit,
        filter: filterEntity,
      );

      // Assert
      expect(result, isA<NetworkSuccess<PaginatedProductsEntity>>());
      final successData =
          (result as NetworkSuccess<PaginatedProductsEntity>).data;
      expect(successData, equals(tPaginatedEntity));

      final captured = verify(
        () => mockProductsRemoteDataSource.getProducts(
          lastDoc: lastDoc,
          limit: limit,
          filter: captureAny(named: 'filter'),
        ),
      ).captured;

      expect(captured.first, isA<ProductsFilterModel>());
      final filterModel = captured.first as ProductsFilterModel;
      expect(filterModel.sortType, filterEntity.sortType);
      expect(filterModel.categoryFilter, filterEntity.categoryFilter);
      verifyNoMoreInteractions(mockProductsRemoteDataSource);
    });

    test('should call remoteDataSource.getProducts with null filter when filter argument is null', () async {
      // Arrange
      when(
        () => mockProductsRemoteDataSource.getProducts(
          lastDoc: any(named: 'lastDoc'),
          limit: any(named: 'limit'),
          filter: any(named: 'filter'),
        ),
      ).thenAnswer((_) async => NetworkSuccess(tPaginatedData));

      // Act
      final result = await sut.getProducts();

      // Assert
      expect(result, isA<NetworkSuccess<PaginatedProductsEntity>>());
      final successData =
          (result as NetworkSuccess<PaginatedProductsEntity>).data;
      expect(successData, equals(tPaginatedEntity));

      verify(
        () => mockProductsRemoteDataSource.getProducts(
          lastDoc: null,
          limit: 10,
          filter: null,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockProductsRemoteDataSource);
    });

    test('should return NetworkFailure with same failure when remoteDataSource returns NetworkFailure', () async {
      // Arrange
      when(
        () => mockProductsRemoteDataSource.getProducts(
          lastDoc: any(named: 'lastDoc'),
          limit: any(named: 'limit'),
          filter: any(named: 'filter'),
        ),
      ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

      // Act
      final result = await sut.getProducts();

      // Assert
      expect(result, isA<NetworkFailure<PaginatedProductsEntity>>());
      final failure =
          (result as NetworkFailure<PaginatedProductsEntity>).failure;
      expect(failure.error, tServerFailure.error);
      verify(
        () => mockProductsRemoteDataSource.getProducts(
          lastDoc: null,
          limit: 10,
          filter: null,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockProductsRemoteDataSource);
    });
  });

  group('getProductDetails', () {
    const tCode = 'APPLE_01';

    test('should call remoteDataSource.getProductDetails with code and return NetworkSuccess with mapped FruitEntity when remoteDataSource succeeds', () async {
      // Arrange
      when(() => mockProductsRemoteDataSource.getProductDetails(any()))
          .thenAnswer((_) async => NetworkSuccess(tFruitModel1));

      // Act
      final result = await sut.getProductDetails(tCode);

      // Assert
      expect(result, isA<NetworkSuccess<FruitEntity>>());
      final successData = (result as NetworkSuccess<FruitEntity>).data;
      expect(successData, equals(tFruitEntity1));
      verify(() => mockProductsRemoteDataSource.getProductDetails(tCode))
          .called(1);
      verifyNoMoreInteractions(mockProductsRemoteDataSource);
    });

    test('should return NetworkFailure with same failure when remoteDataSource returns NetworkFailure', () async {
      // Arrange
      const tNotFoundFailure = ServerFailure(error: 'المنتج غير موجود');
      when(() => mockProductsRemoteDataSource.getProductDetails(any()))
          .thenAnswer((_) async => const NetworkFailure(tNotFoundFailure));

      // Act
      final result = await sut.getProductDetails(tCode);

      // Assert
      expect(result, isA<NetworkFailure<FruitEntity>>());
      final failure = (result as NetworkFailure<FruitEntity>).failure;
      expect(failure.error, tNotFoundFailure.error);
      verify(() => mockProductsRemoteDataSource.getProductDetails(tCode))
          .called(1);
      verifyNoMoreInteractions(mockProductsRemoteDataSource);
    });
  });

  group('Model and Entity Mappings', () {
    test('PaginatedProductsData toEntity should map all properties correctly to PaginatedProductsEntity', () {
      // Arrange
      final paginatedData = PaginatedProductsData(
        fruits: [tFruitModel1],
        lastDoc: 'snapshot_xyz',
        hasMore: false,
      );

      // Act
      final entity = paginatedData.toEntity();

      // Assert
      expect(entity, isA<PaginatedProductsEntity>());
      expect(entity.fruits, equals([tFruitEntity1]));
      expect(entity.lastDoc, 'snapshot_xyz');
      expect(entity.hasMore, isFalse);
    });
  });
}
