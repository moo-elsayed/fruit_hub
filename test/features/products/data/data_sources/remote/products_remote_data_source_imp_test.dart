import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/enums/product_category_filter.dart';
import 'package:fruit_hub/core/enums/product_sort_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/models/review_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/products/data/data_sources/remote/products_remote_data_source_imp.dart';
import 'package:fruit_hub/features/products/data/models/paginated_products_data.dart';
import 'package:fruit_hub/features/products/data/models/products_filter_model.dart';
import 'package:fruit_hub/features/products/domain/entities/products_filter_entity.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ProductsRemoteDataSourceImp sut;

  final Map<String, dynamic> tFruitJson1 = {
    'name': 'تفاح أحمر',
    'description': 'تفاح أحمر طازج ولذيذ',
    'price': 25.0,
    'imagePath': 'assets/images/red_apple.png',
    'code': 'APPLE_01',
    'isFeatured': true,
    'avgRating': 4.5,
    'ratingCount': 10,
    'isOrganic': true,
    'daysUntilExpiration': 14,
    'weightInGrams': 500,
    'numberOfCalories': 52,
    'sellingCount': 100,
    'reviews': [
      {
        'name': 'أحمد',
        'image': 'assets/images/user1.png',
        'description': 'جودة ممتازة',
        'date': '2026-09-01',
        'rating': 5.0,
        'userId': 'user_1',
      },
    ],
  };

  final Map<String, dynamic> tFruitJson2 = {
    'name': 'موز بلدي',
    'description': 'موز طازج ومغذي',
    'price': 15.0,
    'imagePath': 'assets/images/banana.png',
    'code': 'BANANA_01',
    'isFeatured': false,
    'avgRating': 4.0,
    'ratingCount': 5,
    'isOrganic': true,
    'daysUntilExpiration': 5,
    'weightInGrams': 1000,
    'numberOfCalories': 89,
    'sellingCount': 250,
    'reviews': <Map<String, dynamic>>[],
  };

  final Map<String, dynamic> tFruitJson3 = {
    'name': 'مانجو سكري',
    'description': 'مانجو سكري فاخر',
    'price': 50.0,
    'imagePath': 'assets/images/mango.png',
    'code': 'MANGO_01',
    'isFeatured': true,
    'avgRating': 4.9,
    'ratingCount': 30,
    'isOrganic': false,
    'daysUntilExpiration': 7,
    'weightInGrams': 600,
    'numberOfCalories': 60,
    'sellingCount': 50,
    'reviews': <Map<String, dynamic>>[],
  };

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    sut = ProductsRemoteDataSourceImp(firestore: fakeFirestore);
  });

  group('getProducts', () {
    test('should return NetworkSuccess with empty fruits list and hasMore false when collection is empty', () async {
      // Arrange - collection is empty

      // Act
      final result = await sut.getProducts();

      // Assert
      expect(result, isA<NetworkSuccess<PaginatedProductsData>>());
      final paginatedData =
          (result as NetworkSuccess<PaginatedProductsData>).data;
      expect(paginatedData, isNotNull);
      expect(paginatedData!.fruits, isEmpty);
      expect(paginatedData.hasMore, isFalse);
      expect(paginatedData.lastDoc, isNull);
    });

    test('should return NetworkSuccess with all products and hasMore false when total products is less than limit', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('APPLE_01')
          .set(tFruitJson1);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('BANANA_01')
          .set(tFruitJson2);

      // Act
      final result = await sut.getProducts(limit: 5);

      // Assert
      expect(result, isA<NetworkSuccess<PaginatedProductsData>>());
      final paginatedData =
          (result as NetworkSuccess<PaginatedProductsData>).data;
      expect(paginatedData, isNotNull);
      expect(paginatedData!.fruits, hasLength(2));
      expect(paginatedData.hasMore, isFalse);
      expect(paginatedData.lastDoc, isNotNull);
      expect(
        paginatedData.fruits.map((f) => f.code),
        containsAll(['APPLE_01', 'BANANA_01']),
      );
    });

    test('should return NetworkSuccess with limited products and hasMore true when total products equals limit', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('APPLE_01')
          .set(tFruitJson1);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('BANANA_01')
          .set(tFruitJson2);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('MANGO_01')
          .set(tFruitJson3);

      // Act
      final result = await sut.getProducts(limit: 2);

      // Assert
      expect(result, isA<NetworkSuccess<PaginatedProductsData>>());
      final paginatedData =
          (result as NetworkSuccess<PaginatedProductsData>).data;
      expect(paginatedData, isNotNull);
      expect(paginatedData!.fruits, hasLength(2));
      expect(paginatedData.hasMore, isTrue);
      expect(paginatedData.lastDoc, isNotNull);
    });

    test('should return NetworkSuccess with next page of products when lastDoc is provided as DocumentSnapshot', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('APPLE_01')
          .set(tFruitJson1);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('BANANA_01')
          .set(tFruitJson2);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('MANGO_01')
          .set(tFruitJson3);

      const filter = ProductsFilterModel(
        sortType: ProductSortType.priceLowestToHighest,
      );

      // First page
      final firstPageResult = await sut.getProducts(limit: 2, filter: filter);
      final firstPageData =
          (firstPageResult as NetworkSuccess<PaginatedProductsData>).data!;
      final lastDoc = firstPageData.lastDoc as DocumentSnapshot;

      // Act - Second page
      final secondPageResult = await sut.getProducts(
        limit: 2,
        lastDoc: lastDoc,
        filter: filter,
      );

      // Assert
      expect(secondPageResult, isA<NetworkSuccess<PaginatedProductsData>>());
      final secondPageData =
          (secondPageResult as NetworkSuccess<PaginatedProductsData>).data;
      expect(secondPageData, isNotNull);
      expect(secondPageData!.fruits, hasLength(1));
      expect(secondPageData.hasMore, isFalse);
      final firstPageCodes = firstPageData.fruits.map((f) => f.code).toSet();
      final secondPageCode = secondPageData.fruits.first.code;
      expect(firstPageCodes.contains(secondPageCode), isFalse);
    });

    test('should return NetworkSuccess with next page of products when lastDoc is provided without custom filter', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('DOC_1')
          .set(tFruitJson1);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('DOC_2')
          .set(tFruitJson2);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('DOC_3')
          .set(tFruitJson3);

      // First page
      final firstPageResult = await sut.getProducts(limit: 2);
      final firstPageData =
          (firstPageResult as NetworkSuccess<PaginatedProductsData>).data!;
      final lastDoc = firstPageData.lastDoc as DocumentSnapshot;

      // Act - Second page
      final secondPageResult = await sut.getProducts(
        limit: 2,
        lastDoc: lastDoc,
      );

      // Assert
      expect(secondPageResult, isA<NetworkSuccess<PaginatedProductsData>>());
      final secondPageData =
          (secondPageResult as NetworkSuccess<PaginatedProductsData>).data;
      expect(secondPageData, isNotNull);
      expect(secondPageData!.fruits, hasLength(1));
      expect(secondPageData.hasMore, isFalse);
      final firstPageCodes = firstPageData.fruits.map((f) => f.code).toSet();
      final secondPageCode = secondPageData.fruits.first.code;
      expect(firstPageCodes.contains(secondPageCode), isFalse);
    });

    test(
      'should ignore lastDoc when lastDoc is not a DocumentSnapshot',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .doc('APPLE_01')
            .set(tFruitJson1);
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .doc('BANANA_01')
            .set(tFruitJson2);

        // Act
        final result = await sut.getProducts(
          lastDoc: 'invalid_non_snapshot_doc',
        );

        // Assert
        expect(result, isA<NetworkSuccess<PaginatedProductsData>>());
        final paginatedData =
            (result as NetworkSuccess<PaginatedProductsData>).data;
        expect(paginatedData, isNotNull);
        expect(paginatedData!.fruits, hasLength(2));
      },
    );

    test('should filter products by organic category when ProductCategoryFilter.organic is provided', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('APPLE_01')
          .set(tFruitJson1); // isOrganic: true
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('BANANA_01')
          .set(tFruitJson2); // isOrganic: true
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('MANGO_01')
          .set(tFruitJson3); // isOrganic: false

      const filter = ProductsFilterModel(
        categoryFilter: ProductCategoryFilter.organic,
      );

      // Act
      final result = await sut.getProducts(filter: filter);

      // Assert
      expect(result, isA<NetworkSuccess<PaginatedProductsData>>());
      final paginatedData =
          (result as NetworkSuccess<PaginatedProductsData>).data;
      expect(paginatedData, isNotNull);
      expect(paginatedData!.fruits, hasLength(2));
      for (final fruit in paginatedData.fruits) {
        expect(fruit.isOrganic, isTrue);
      }
    });

    test('should filter products by featured category when ProductCategoryFilter.featured is provided', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('APPLE_01')
          .set(tFruitJson1); // isFeatured: true
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('BANANA_01')
          .set(tFruitJson2); // isFeatured: false
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('MANGO_01')
          .set(tFruitJson3); // isFeatured: true

      const filter = ProductsFilterModel(
        categoryFilter: ProductCategoryFilter.featured,
      );

      // Act
      final result = await sut.getProducts(filter: filter);

      // Assert
      expect(result, isA<NetworkSuccess<PaginatedProductsData>>());
      final paginatedData =
          (result as NetworkSuccess<PaginatedProductsData>).data;
      expect(paginatedData, isNotNull);
      expect(paginatedData!.fruits, hasLength(2));
      for (final fruit in paginatedData.fruits) {
        expect(fruit.isFeatured, isTrue);
      }
    });

    test(
      'should return all products when ProductCategoryFilter.all is provided',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .doc('APPLE_01')
            .set(tFruitJson1);
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .doc('BANANA_01')
            .set(tFruitJson2);
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .doc('MANGO_01')
            .set(tFruitJson3);

        const filter = ProductsFilterModel(
          categoryFilter: ProductCategoryFilter.all,
        );

        // Act
        final result = await sut.getProducts(filter: filter);

        // Assert
        expect(result, isA<NetworkSuccess<PaginatedProductsData>>());
        final paginatedData =
            (result as NetworkSuccess<PaginatedProductsData>).data;
        expect(paginatedData, isNotNull);
        expect(paginatedData!.fruits, hasLength(3));
      },
    );

    test('should order products by price ascending when ProductSortType.priceLowestToHighest is provided', () async {
      // Arrange: prices: Banana (15.0), Apple (25.0), Mango (50.0)
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('APPLE_01')
          .set(tFruitJson1);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('BANANA_01')
          .set(tFruitJson2);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('MANGO_01')
          .set(tFruitJson3);

      const filter = ProductsFilterModel(
        sortType: ProductSortType.priceLowestToHighest,
      );

      // Act
      final result = await sut.getProducts(filter: filter);

      // Assert
      expect(result, isA<NetworkSuccess<PaginatedProductsData>>());
      final fruits =
          (result as NetworkSuccess<PaginatedProductsData>).data!.fruits;
      expect(fruits, hasLength(3));
      expect(fruits[0].price, 15.0);
      expect(fruits[1].price, 25.0);
      expect(fruits[2].price, 50.0);
    });

    test('should order products by price descending when ProductSortType.priceHighestToLowest is provided', () async {
      // Arrange: prices: Banana (15.0), Apple (25.0), Mango (50.0)
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('APPLE_01')
          .set(tFruitJson1);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('BANANA_01')
          .set(tFruitJson2);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('MANGO_01')
          .set(tFruitJson3);

      const filter = ProductsFilterModel(
        sortType: ProductSortType.priceHighestToLowest,
      );

      // Act
      final result = await sut.getProducts(filter: filter);

      // Assert
      expect(result, isA<NetworkSuccess<PaginatedProductsData>>());
      final fruits =
          (result as NetworkSuccess<PaginatedProductsData>).data!.fruits;
      expect(fruits, hasLength(3));
      expect(fruits[0].price, 50.0);
      expect(fruits[1].price, 25.0);
      expect(fruits[2].price, 15.0);
    });

    test('should order products by rating descending when ProductSortType.topRated is provided', () async {
      // Arrange: ratings: Banana (4.0), Apple (4.5), Mango (4.9)
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('APPLE_01')
          .set(tFruitJson1);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('BANANA_01')
          .set(tFruitJson2);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('MANGO_01')
          .set(tFruitJson3);

      const filter = ProductsFilterModel(sortType: ProductSortType.topRated);

      // Act
      final result = await sut.getProducts(filter: filter);

      // Assert
      expect(result, isA<NetworkSuccess<PaginatedProductsData>>());
      final fruits =
          (result as NetworkSuccess<PaginatedProductsData>).data!.fruits;
      expect(fruits, hasLength(3));
      expect(fruits[0].avgRating, 4.9);
      expect(fruits[1].avgRating, 4.5);
      expect(fruits[2].avgRating, 4.0);
    });

    test('should order products by selling count descending when ProductSortType.mostPopular is provided', () async {
      // Arrange: selling counts: Mango (50), Apple (100), Banana (250)
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('APPLE_01')
          .set(tFruitJson1);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('BANANA_01')
          .set(tFruitJson2);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('MANGO_01')
          .set(tFruitJson3);

      const filter = ProductsFilterModel(sortType: ProductSortType.mostPopular);

      // Act
      final result = await sut.getProducts(filter: filter);

      // Assert
      expect(result, isA<NetworkSuccess<PaginatedProductsData>>());
      final fruits =
          (result as NetworkSuccess<PaginatedProductsData>).data!.fruits;
      expect(fruits, hasLength(3));
      expect(fruits[0].sellingCount, 250);
      expect(fruits[1].sellingCount, 100);
      expect(fruits[2].sellingCount, 50);
    });

    test('should order products by name ascending when ProductSortType.alphabetical is provided', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('DOC_C')
          .set({'name': 'C Cherry'});
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('DOC_A')
          .set({'name': 'A Apple'});
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('DOC_B')
          .set({'name': 'B Banana'});

      const filter = ProductsFilterModel(
        sortType: ProductSortType.alphabetical,
      );

      // Act
      final result = await sut.getProducts(filter: filter);

      // Assert
      expect(result, isA<NetworkSuccess<PaginatedProductsData>>());
      final fruits =
          (result as NetworkSuccess<PaginatedProductsData>).data!.fruits;
      expect(fruits, hasLength(3));
      expect(fruits[0].name, 'A Apple');
      expect(fruits[1].name, 'B Banana');
      expect(fruits[2].name, 'C Cherry');
    });

    test(
      'should not apply ordering when ProductSortType.none is provided',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .doc('APPLE_01')
            .set(tFruitJson1);
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .doc('BANANA_01')
            .set(tFruitJson2);

        const filter = ProductsFilterModel(sortType: ProductSortType.none);

        // Act
        final result = await sut.getProducts(filter: filter);

        // Assert
        expect(result, isA<NetworkSuccess<PaginatedProductsData>>());
        final fruits =
            (result as NetworkSuccess<PaginatedProductsData>).data!.fruits;
        expect(fruits, hasLength(2));
      },
    );

    test('should apply both category filter and sorting when both are provided in filter', () async {
      // Arrange:
      // Apple: isFeatured: true, price: 25.0
      // Banana: isFeatured: false, price: 15.0
      // Mango: isFeatured: true, price: 50.0
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('APPLE_01')
          .set(tFruitJson1);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('BANANA_01')
          .set(tFruitJson2);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('MANGO_01')
          .set(tFruitJson3);

      const filter = ProductsFilterModel(
        categoryFilter: ProductCategoryFilter.featured,
        sortType: ProductSortType.priceLowestToHighest,
      );

      // Act
      final result = await sut.getProducts(filter: filter);

      // Assert
      expect(result, isA<NetworkSuccess<PaginatedProductsData>>());
      final fruits =
          (result as NetworkSuccess<PaginatedProductsData>).data!.fruits;
      expect(fruits, hasLength(2));
      expect(fruits[0].code, 'APPLE_01');
      expect(fruits[0].price, 25.0);
      expect(fruits[1].code, 'MANGO_01');
      expect(fruits[1].price, 50.0);
    });

    test('should return NetworkFailure with ServerFailure when document data has invalid format causing exception', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('CORRUPT_01')
          .set({'name': 'تالف', 'reviews': 'invalid_reviews_string_not_list'});

      // Act
      final result = await sut.getProducts();

      // Assert
      expect(result, isA<NetworkFailure<PaginatedProductsData>>());
      final failure = (result as NetworkFailure<PaginatedProductsData>).failure;
      expect(failure.error, AppStrings.unexpectedError);
    });
  });

  group('getProductDetails', () {
    test('should return NetworkSuccess with FruitModel when product with given code exists', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('APPLE_01')
          .set(tFruitJson1);

      // Act
      final result = await sut.getProductDetails('APPLE_01');

      // Assert
      expect(result, isA<NetworkSuccess<FruitModel>>());
      final fruit = (result as NetworkSuccess<FruitModel>).data;
      expect(fruit, isNotNull);
      expect(fruit!.code, 'APPLE_01');
      expect(fruit.name, 'تفاح أحمر');
      expect(fruit.description, 'تفاح أحمر طازج ولذيذ');
      expect(fruit.price, 25.0);
      expect(fruit.imagePath, 'assets/images/red_apple.png');
      expect(fruit.isFeatured, isTrue);
      expect(fruit.avgRating, 4.5);
      expect(fruit.ratingCount, 10);
      expect(fruit.isOrganic, isTrue);
      expect(fruit.daysUntilExpiration, 14);
      expect(fruit.weightInGrams, 500);
      expect(fruit.numberOfCalories, 52);
      expect(fruit.sellingCount, 100);
      expect(fruit.reviews, hasLength(1));
      expect(fruit.reviews.first.name, 'أحمد');
    });

    test('should return NetworkFailure with not found error when product with given code does not exist', () async {
      // Arrange - document does not exist

      // Act
      final result = await sut.getProductDetails('NON_EXISTING_CODE');

      // Assert
      expect(result, isA<NetworkFailure<FruitModel>>());
      final failure = (result as NetworkFailure<FruitModel>).failure;
      expect(failure.error, AppStrings.notFoundError);
    });

    test('should return NetworkFailure with ServerFailure when product document data is corrupted', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('CORRUPT_CODE')
          .set({'name': 'فاسد', 'reviews': 'not_a_list'});

      // Act
      final result = await sut.getProductDetails('CORRUPT_CODE');

      // Assert
      expect(result, isA<NetworkFailure<FruitModel>>());
      final failure = (result as NetworkFailure<FruitModel>).failure;
      expect(failure.error, AppStrings.unexpectedError);
    });
  });

  group('Model and Entity Mappings', () {
    test('ProductsFilterModel toEntity should map all properties correctly to ProductsFilterEntity', () {
      // Arrange
      const model = ProductsFilterModel(
        sortType: ProductSortType.priceHighestToLowest,
        categoryFilter: ProductCategoryFilter.organic,
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity, isA<ProductsFilterEntity>());
      expect(entity.sortType, ProductSortType.priceHighestToLowest);
      expect(entity.categoryFilter, ProductCategoryFilter.organic);
    });

    test('ProductsFilterModel fromEntity should map all properties correctly from ProductsFilterEntity', () {
      // Arrange
      const entity = ProductsFilterEntity(
        sortType: ProductSortType.topRated,
        categoryFilter: ProductCategoryFilter.featured,
      );

      // Act
      final model = ProductsFilterModel.fromEntity(entity);

      // Assert
      expect(model, isA<ProductsFilterModel>());
      expect(model.sortType, ProductSortType.topRated);
      expect(model.categoryFilter, ProductCategoryFilter.featured);
    });

    test('ProductsFilterModel should have proper default values', () {
      // Arrange & Act
      const model = ProductsFilterModel();

      // Assert
      expect(model.sortType, ProductSortType.none);
      expect(model.categoryFilter, ProductCategoryFilter.all);
    });

    test('PaginatedProductsData should initialize with given values', () {
      // Arrange
      final fruits = [FruitModel.fromJson(tFruitJson1)];
      const lastDoc = 'mock_snapshot';

      // Act
      final paginatedData = PaginatedProductsData(
        fruits: fruits,
        lastDoc: lastDoc,
        hasMore: true,
      );

      // Assert
      expect(paginatedData.fruits, equals(fruits));
      expect(paginatedData.lastDoc, equals(lastDoc));
      expect(paginatedData.hasMore, isTrue);
    });

    test('FruitModel fromJson should parse complete json correctly with correct types and nested reviews', () {
      // Arrange
      final json = {
        'name': 'عنب',
        'description': 'عنب بناتي بدون بذور',
        'price': 35.5,
        'imagePath': 'assets/images/grapes.png',
        'code': 'GRAPES_01',
        'isFeatured': true,
        'avgRating': 4.7,
        'ratingCount': 12,
        'isOrganic': true,
        'daysUntilExpiration': 8,
        'weightInGrams': 750,
        'numberOfCalories': 67,
        'sellingCount': 80,
        'reviews': [
          {
            'name': 'سارة',
            'image': 'assets/images/user2.png',
            'description': 'طازج ولذيذ',
            'date': '2026-09-10',
            'rating': 4.5,
            'userId': 'user_456',
          },
        ],
      };

      // Act
      final model = FruitModel.fromJson(json);

      // Assert
      expect(model.name, 'عنب');
      expect(model.description, 'عنب بناتي بدون بذور');
      expect(model.price, 35.5);
      expect(model.imagePath, 'assets/images/grapes.png');
      expect(model.code, 'GRAPES_01');
      expect(model.isFeatured, isTrue);
      expect(model.avgRating, 4.7);
      expect(model.ratingCount, 12);
      expect(model.isOrganic, isTrue);
      expect(model.daysUntilExpiration, 8);
      expect(model.weightInGrams, 750);
      expect(model.numberOfCalories, 67);
      expect(model.sellingCount, 80);
      expect(model.reviews, hasLength(1));
      expect(model.reviews.first.name, 'سارة');
      expect(model.reviews.first.rating, 4.5);
      expect(model.reviews.first.userId, 'user_456');
    });

    test('FruitModel fromJson should handle missing and null fields with default fallbacks', () {
      // Arrange
      final emptyJson = <String, dynamic>{};

      // Act
      final model = FruitModel.fromJson(emptyJson);

      // Assert
      expect(model.name, '');
      expect(model.description, '');
      expect(model.price, 0.0);
      expect(model.imagePath, '');
      expect(model.code, '');
      expect(model.isFeatured, isFalse);
      expect(model.avgRating, 0);
      expect(model.ratingCount, 0);
      expect(model.isOrganic, isFalse);
      expect(model.daysUntilExpiration, 0);
      expect(model.weightInGrams, 0);
      expect(model.numberOfCalories, 0);
      expect(model.sellingCount, 0);
      expect(model.reviews, isEmpty);
    });

    test('FruitModel fromJson should support numeric type coercion for price and fallback weightInGrams from unitAmount', () {
      // Arrange
      final jsonWithCoercions = {
        'price': 20, // int coerced to double
        'unitAmount': 350, // fallback for weightInGrams
      };

      // Act
      final model = FruitModel.fromJson(jsonWithCoercions);

      // Assert
      expect(model.price, 20.0);
      expect(model.price, isA<double>());
      expect(model.weightInGrams, 350);
    });

    test('FruitModel toEntity should map all properties correctly to FruitEntity including nested reviews', () {
      // Arrange
      const reviewModel = ReviewModel(
        name: 'محمد',
        image: 'assets/images/user.png',
        description: 'رائع جداً',
        date: '2026-09-15',
        rating: 4.8,
        userId: 'user_123',
      );

      final fruitModel = FruitModel(
        name: 'مانجو',
        description: 'مانجو سكري فاخر',
        price: 45.0,
        imagePath: 'assets/images/mango.png',
        code: 'MANGO_01',
        isFeatured: true,
        avgRating: 4.9,
        ratingCount: 30,
        isOrganic: true,
        daysUntilExpiration: 7,
        weightInGrams: 500,
        numberOfCalories: 60,
        sellingCount: 150,
        reviews: [reviewModel],
      );

      // Act
      final entity = fruitModel.toEntity();

      // Assert
      expect(entity, isA<FruitEntity>());
      expect(entity.name, fruitModel.name);
      expect(entity.description, fruitModel.description);
      expect(entity.price, fruitModel.price);
      expect(entity.imagePath, fruitModel.imagePath);
      expect(entity.code, fruitModel.code);
      expect(entity.isFeatured, fruitModel.isFeatured);
      expect(entity.avgRating, fruitModel.avgRating);
      expect(entity.ratingCount, fruitModel.ratingCount);
      expect(entity.isOrganic, fruitModel.isOrganic);
      expect(entity.daysUntilExpiration, fruitModel.daysUntilExpiration);
      expect(entity.weightInGrams, fruitModel.weightInGrams);
      expect(entity.numberOfCalories, fruitModel.numberOfCalories);
      expect(entity.reviews, hasLength(1));
      expect(entity.reviews.first.name, reviewModel.name);
      expect(entity.reviews.first.image, reviewModel.image);
      expect(entity.reviews.first.description, reviewModel.description);
      expect(entity.reviews.first.date, reviewModel.date);
      expect(entity.reviews.first.rating, reviewModel.rating);
      expect(entity.reviews.first.userId, reviewModel.userId);
    });
  });
}
