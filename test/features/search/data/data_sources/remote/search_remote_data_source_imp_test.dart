import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/models/review_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/search/data/data_sources/remote/search_remote_data_source_imp.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SearchRemoteDataSourceImp sut;

  final Map<String, dynamic> tFruitJson1 = {
    'name': 'تفاح أحمر',
    'description': 'تفاح أحمر طازج ولذيذ',
    'price': 25.5,
    'imagePath': 'assets/images/red_apple.png',
    'code': 'APPLE_RED_01',
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
    'name': 'تفاح أخضر',
    'description': 'تفاح أخضر حامض وطازج',
    'price': 30.0,
    'imagePath': 'assets/images/green_apple.png',
    'code': 'APPLE_GREEN_02',
    'isFeatured': false,
    'avgRating': 4.0,
    'ratingCount': 5,
    'isOrganic': false,
    'daysUntilExpiration': 10,
    'weightInGrams': 450,
    'numberOfCalories': 48,
    'sellingCount': 50,
    'reviews': <Map<String, dynamic>>[],
  };

  final Map<String, dynamic> tFruitJson3 = {
    'name': 'موز بلدي',
    'description': 'موز طازج ومغذي',
    'price': 15.0,
    'imagePath': 'assets/images/banana.png',
    'code': 'BANANA_01',
    'isFeatured': true,
    'avgRating': 4.8,
    'ratingCount': 25,
    'isOrganic': true,
    'daysUntilExpiration': 5,
    'weightInGrams': 1000,
    'numberOfCalories': 89,
    'sellingCount': 200,
    'reviews': <Map<String, dynamic>>[],
  };

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    sut = SearchRemoteDataSourceImp(firestore: fakeFirestore);
  });

  group('searchFruits', () {
    test(
      'should return NetworkSuccess with matching fruits when matching documents exist',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .add(tFruitJson1);
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .add(tFruitJson2);
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .add(tFruitJson3);

        // Act
        final result = await sut.searchFruits('تفاح');

        // Assert
        expect(result, isA<NetworkSuccess<List<FruitModel>>>());
        final fruits = (result as NetworkSuccess<List<FruitModel>>).data;
        expect(fruits, isNotNull);
        expect(fruits, hasLength(2));
        expect(
          fruits!.map((fruit) => fruit.name).toList(),
          containsAll(['تفاح أحمر', 'تفاح أخضر']),
        );
        final firstFruit = fruits.firstWhere((f) => f.name == 'تفاح أحمر');
        expect(firstFruit.description, 'تفاح أحمر طازج ولذيذ');
        expect(firstFruit.price, 25.5);
        expect(firstFruit.code, 'APPLE_RED_01');
        expect(firstFruit.isFeatured, isTrue);
        expect(firstFruit.isOrganic, isTrue);
        expect(firstFruit.reviews, hasLength(1));
        expect(firstFruit.reviews.first.name, 'أحمد');

        final secondFruit = fruits.firstWhere((f) => f.name == 'تفاح أخضر');
        expect(secondFruit.description, 'تفاح أخضر حامض وطازج');
        expect(secondFruit.price, 30.0);
        expect(secondFruit.code, 'APPLE_GREEN_02');
        expect(secondFruit.isFeatured, isFalse);
        expect(secondFruit.isOrganic, isFalse);
        expect(secondFruit.reviews, isEmpty);
      },
    );

    test(
      'should return NetworkSuccess with empty list when no products match query',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .add(tFruitJson1);
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .add(tFruitJson2);

        // Act
        final result = await sut.searchFruits('برتقال');

        // Assert
        expect(result, isA<NetworkSuccess<List<FruitModel>>>());
        final fruits = (result as NetworkSuccess<List<FruitModel>>).data;
        expect(fruits, isNotNull);
        expect(fruits, isEmpty);
      },
    );

    test(
      'should return NetworkSuccess with empty list when products collection is empty',
      () async {
        // Arrange - collection is empty

        // Act
        final result = await sut.searchFruits('تفاح');

        // Assert
        expect(result, isA<NetworkSuccess<List<FruitModel>>>());
        final fruits = (result as NetworkSuccess<List<FruitModel>>).data;
        expect(fruits, isNotNull);
        expect(fruits, isEmpty);
      },
    );

    test(
      'should return NetworkSuccess with items within exact prefix range',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .add({'name': 'Apple Red'});
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .add({'name': 'Apple Green'});
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .add({'name': 'Apricot'});
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .add({'name': 'Banana'});

        // Act
        final result = await sut.searchFruits('Apple');

        // Assert
        expect(result, isA<NetworkSuccess<List<FruitModel>>>());
        final fruits = (result as NetworkSuccess<List<FruitModel>>).data;
        expect(fruits, isNotNull);
        expect(fruits, hasLength(2));
        final fruitNames = fruits!.map((f) => f.name).toList();
        expect(fruitNames, containsAll(['Apple Red', 'Apple Green']));
        expect(fruitNames, isNot(contains('Apricot')));
        expect(fruitNames, isNot(contains('Banana')));
      },
    );

    test(
      'should return NetworkFailure with ServerFailure when document data has invalid format causing exception',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .add({
              'name': 'خوخ',
              'reviews': 'invalid_format_not_a_list',
            });

        // Act
        final result = await sut.searchFruits('خوخ');

        // Assert
        expect(result, isA<NetworkFailure<List<FruitModel>>>());
        final failure = (result as NetworkFailure<List<FruitModel>>).failure;
        expect(failure.error, AppStrings.unexpectedError);
      },
    );
  });

  group('Model and Entity Mappings', () {
    test(
      'FruitModel toEntity should map all properties correctly to FruitEntity including nested reviews',
      () {
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
      },
    );

    test(
      'FruitModel fromJson should parse complete json correctly with correct types and nested reviews',
      () {
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
      },
    );

    test(
      'FruitModel fromJson should handle missing and null fields with default fallbacks',
      () {
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
      },
    );

    test(
      'FruitModel fromJson should support numeric type coercion for price and fallback weightInGrams from unitAmount',
      () {
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
      },
    );

    test(
      'ReviewModel toEntity and fromEntity should map all properties correctly',
      () {
        // Arrange
        const entity = ReviewEntity(
          name: 'خالد',
          image: 'assets/images/khaled.png',
          description: 'خدمة ممتازة',
          date: '2026-09-12',
          rating: 4.9,
          userId: 'user_khaled',
        );

        // Act
        final model = ReviewModel.fromEntity(entity);

        // Assert
        expect(model.name, entity.name);
        expect(model.image, entity.image);
        expect(model.description, entity.description);
        expect(model.date, entity.date);
        expect(model.rating, entity.rating);
        expect(model.userId, entity.userId);

        final mappedEntity = model.toEntity();
        expect(mappedEntity.name, entity.name);
        expect(mappedEntity.image, entity.image);
        expect(mappedEntity.description, entity.description);
        expect(mappedEntity.date, entity.date);
        expect(mappedEntity.rating, entity.rating);
        expect(mappedEntity.userId, entity.userId);
      },
    );

    test(
      'ReviewModel fromJson and toJson should serialize and deserialize correctly with conditional userId',
      () {
        // Arrange
        final jsonWithUser = {
          'name': 'فاطمة',
          'description': 'منتج ممتاز جداً',
          'rating': 5.0,
          'date': '2026-09-14',
          'image': 'assets/images/fatima.png',
          'userId': 'user_fatima',
        };

        // Act
        final model = ReviewModel.fromJson(jsonWithUser);
        final outputJson = model.toJson();

        // Assert
        expect(model.name, 'فاطمة');
        expect(model.description, 'منتج ممتاز جداً');
        expect(model.rating, 5.0);
        expect(model.date, '2026-09-14');
        expect(model.image, 'assets/images/fatima.png');
        expect(model.userId, 'user_fatima');
        expect(outputJson, equals(jsonWithUser));

        // Test without userId - should omit userId from toJson()
        const modelWithoutUser = ReviewModel(
          name: 'مجهول',
          image: '',
          description: 'تعليق عادي',
          date: '2026-09-15',
          rating: 3.5,
        );
        final outputWithoutUser = modelWithoutUser.toJson();
        expect(outputWithoutUser.containsKey('userId'), isFalse);
      },
    );

    test(
      'ReviewModel fromJson should handle uId alias fallback and missing fields',
      () {
        // Arrange
        final jsonWithUidAlias = {
          'rating': 4, // int coerced to double
          'uId': 'alias_uid_123',
        };

        // Act
        final model = ReviewModel.fromJson(jsonWithUidAlias);

        // Assert
        expect(model.name, '');
        expect(model.description, '');
        expect(model.rating, 4.0);
        expect(model.rating, isA<double>());
        expect(model.date, '');
        expect(model.image, '');
        expect(model.userId, 'alias_uid_123');
      },
    );
  });
}
