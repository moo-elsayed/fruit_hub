import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/models/review_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/home/data/data_sources/remote/home_remote_data_source_imp.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late HomeRemoteDataSourceImp sut;

  final Map<String, dynamic> tReviewJson1 = {
    'name': 'أحمد علي',
    'image': 'assets/images/user1.png',
    'description': 'منتج ممتاز وطازج جداً',
    'date': '2026-09-15',
    'rating': 4.5,
    'userId': 'user_001',
  };

  final Map<String, dynamic> tReviewJson2 = {
    'name': 'سارة محمود',
    'image': 'assets/images/user2.png',
    'description': 'جودة رائعة وتوصيل سريع',
    'date': '2026-09-18',
    'rating': 5.0,
    'userId': 'user_002',
  };

  Map<String, dynamic> createProductJson({
    required String code,
    required String name,
    required int sellingCount,
    double price = 25.0,
    List<Map<String, dynamic>>? reviews,
  }) => {
    'code': code,
    'name': name,
    'description': 'وصف لمنتج $name',
    'price': price,
    'imagePath': 'assets/images/$code.png',
    'isFeatured': true,
    'avgRating': 4.8,
    'ratingCount': 10,
    'isOrganic': true,
    'daysUntilExpiration': 7,
    'weightInGrams': 1000,
    'numberOfCalories': 52,
    'reviews': reviews ?? [tReviewJson1],
    'sellingCount': sellingCount,
  };

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    sut = HomeRemoteDataSourceImp(firestore: fakeFirestore);
  });

  group('HomeRemoteDataSourceImp - getBestSellerProducts', () {
    test('should return NetworkSuccess with empty list when no products exist in firestore', () async {
      // Arrange (firestore is empty)

      // Act
      final result = await sut.getBestSellerProducts();

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitModel>>>());
      final data = (result as NetworkSuccess<List<FruitModel>>).data;
      expect(data, isEmpty);
    });

    test('should return NetworkSuccess with products sorted by sellingCount descending', () async {
      // Arrange
      final product1 = createProductJson(
        code: 'PROD_1',
        name: 'برتقال',
        sellingCount: 50,
      );
      final product2 = createProductJson(
        code: 'PROD_2',
        name: 'تفاح',
        sellingCount: 150,
      );
      final product3 = createProductJson(
        code: 'PROD_3',
        name: 'موز',
        sellingCount: 80,
      );

      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('p1')
          .set(product1);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('p2')
          .set(product2);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('p3')
          .set(product3);

      // Act
      final result = await sut.getBestSellerProducts();

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitModel>>>());
      final data = (result as NetworkSuccess<List<FruitModel>>).data!;
      expect(data.length, 3);
      expect(data[0].code, 'PROD_2');
      expect(data[0].sellingCount, 150);
      expect(data[1].code, 'PROD_3');
      expect(data[1].sellingCount, 80);
      expect(data[2].code, 'PROD_1');
      expect(data[2].sellingCount, 50);
    });

    test(
      'should limit results to at most 6 products even when more than 6 exist',
      () async {
        // Arrange - seed 8 products with different selling counts
        for (int i = 1; i <= 8; i++) {
          final product = createProductJson(
            code: 'PROD_$i',
            name: 'منتج $i',
            sellingCount: i * 10,
          );
          await fakeFirestore
              .collection(BackendEndpoints.productsCollection)
              .doc('p$i')
              .set(product);
        }

        // Act
        final result = await sut.getBestSellerProducts();

        // Assert
        expect(result, isA<NetworkSuccess<List<FruitModel>>>());
        final data = (result as NetworkSuccess<List<FruitModel>>).data!;
        expect(data.length, 6);
        // The highest selling counts should be PROD_8 (80) down to PROD_3 (30)
        expect(data[0].code, 'PROD_8');
        expect(data[0].sellingCount, 80);
        expect(data[5].code, 'PROD_3');
        expect(data[5].sellingCount, 30);
      },
    );

    test('should map all product fields and review models correctly', () async {
      // Arrange
      final productWithMultipleReviews = createProductJson(
        code: 'MANGO_01',
        name: 'مانجو كيت',
        sellingCount: 200,
        price: 45.0,
        reviews: [tReviewJson1, tReviewJson2],
      );

      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('mango')
          .set(productWithMultipleReviews);

      // Act
      final result = await sut.getBestSellerProducts();

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitModel>>>());
      final data = (result as NetworkSuccess<List<FruitModel>>).data!;
      expect(data.length, 1);
      final item = data.first;
      expect(item.code, 'MANGO_01');
      expect(item.name, 'مانجو كيت');
      expect(item.price, 45.0);
      expect(item.sellingCount, 200);
      expect(item.reviews.length, 2);
      expect(item.reviews[0].name, 'أحمد علي');
      expect(item.reviews[0].rating, 4.5);
      expect(item.reviews[1].name, 'سارة محمود');
      expect(item.reviews[1].rating, 5.0);
    });
  });

  group('Model and Entity Mappings - FruitModel & ReviewModel', () {
    test('should correctly parse FruitModel from json with all properties', () {
      // Arrange
      final json = {
        'name': 'فراولة',
        'description': 'فراولة طازجة ولذيذة',
        'price': 30.0,
        'imagePath': 'assets/images/strawberry.png',
        'code': 'STRAW_01',
        'isFeatured': true,
        'avgRating': 4.7,
        'ratingCount': 25,
        'isOrganic': true,
        'daysUntilExpiration': 5,
        'weightInGrams': 500,
        'numberOfCalories': 32,
        'reviews': [tReviewJson1],
        'sellingCount': 120,
      };

      // Act
      final model = FruitModel.fromJson(json);

      // Assert
      expect(model.name, 'فراولة');
      expect(model.description, 'فراولة طازجة ولذيذة');
      expect(model.price, 30.0);
      expect(model.imagePath, 'assets/images/strawberry.png');
      expect(model.code, 'STRAW_01');
      expect(model.isFeatured, true);
      expect(model.avgRating, 4.7);
      expect(model.ratingCount, 25);
      expect(model.isOrganic, true);
      expect(model.daysUntilExpiration, 5);
      expect(model.weightInGrams, 500);
      expect(model.numberOfCalories, 32);
      expect(model.sellingCount, 120);
      expect(model.reviews.length, 1);
    });

    test('should fallback to safe default values when json fields are missing or null', () {
      // Arrange
      final Map<String, dynamic> emptyJson = {};

      // Act
      final model = FruitModel.fromJson(emptyJson);

      // Assert
      expect(model.name, '');
      expect(model.description, '');
      expect(model.price, 0.0);
      expect(model.imagePath, '');
      expect(model.code, '');
      expect(model.isFeatured, false);
      expect(model.avgRating, 0);
      expect(model.ratingCount, 0);
      expect(model.isOrganic, false);
      expect(model.daysUntilExpiration, 0);
      expect(model.weightInGrams, 0);
      expect(model.numberOfCalories, 0);
      expect(model.sellingCount, 0);
      expect(model.reviews, isEmpty);
    });

    test('should coerce int price and numeric types to double in FruitModel.fromJson', () {
      // Arrange
      final json = {
        'name': 'عنب',
        'price': 40, // int instead of double
        'avgRating': 4, // int instead of double
        'ratingCount': 15,
        'daysUntilExpiration': 10,
        'weightInGrams': 1000,
        'numberOfCalories': 67,
        'sellingCount': 90,
      };

      // Act
      final model = FruitModel.fromJson(json);

      // Assert
      expect(model.price, 40.0);
      expect(model.price, isA<double>());
      expect(model.avgRating, 4);
    });

    test('should support alternative unitAmount key for weightInGrams in FruitModel.fromJson', () {
      // Arrange
      final json = {
        'name': 'بطيخ',
        'unitAmount': 2500, // alternate key
      };

      // Act
      final model = FruitModel.fromJson(json);

      // Assert
      expect(model.weightInGrams, 2500);
    });

    test('should map FruitModel to FruitEntity accurately via toEntity()', () {
      // Arrange
      final model = FruitModel(
        name: 'رمان',
        description: 'رمان سكري طازج',
        price: 35.0,
        imagePath: 'assets/images/pomegranate.png',
        code: 'POM_01',
        isFeatured: true,
        avgRating: 4.9,
        ratingCount: 30,
        isOrganic: true,
        daysUntilExpiration: 14,
        weightInGrams: 800,
        numberOfCalories: 83,
        sellingCount: 75,
        reviews: [
          const ReviewModel(
            name: 'محمد خالد',
            image: 'assets/images/user3.png',
            description: 'طعم رائع',
            date: '2026-09-20',
            rating: 5.0,
            userId: 'u_123',
          ),
        ],
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity, isA<FruitEntity>());
      expect(entity.name, model.name);
      expect(entity.description, model.description);
      expect(entity.price, model.price);
      expect(entity.imagePath, model.imagePath);
      expect(entity.code, model.code);
      expect(entity.isFeatured, model.isFeatured);
      expect(entity.avgRating, model.avgRating);
      expect(entity.ratingCount, model.ratingCount);
      expect(entity.isOrganic, model.isOrganic);
      expect(entity.daysUntilExpiration, model.daysUntilExpiration);
      expect(entity.weightInGrams, model.weightInGrams);
      expect(entity.numberOfCalories, model.numberOfCalories);
      expect(entity.reviews.length, 1);
      expect(entity.reviews.first, isA<ReviewEntity>());
      expect(entity.reviews.first.name, 'محمد خالد');
      expect(entity.reviews.first.rating, 5.0);
    });

    test('should correctly parse ReviewModel from and to json', () {
      // Arrange
      final json = {
        'name': 'كريم حسن',
        'description': 'تجربة ممتازة',
        'rating': 4.0,
        'date': '2026-09-22',
        'image': 'avatar.png',
        'userId': 'usr_99',
      };

      // Act
      final model = ReviewModel.fromJson(json);
      final convertedJson = model.toJson();

      // Assert
      expect(model.name, 'كريم حسن');
      expect(model.description, 'تجربة ممتازة');
      expect(model.rating, 4.0);
      expect(model.date, '2026-09-22');
      expect(model.image, 'avatar.png');
      expect(model.userId, 'usr_99');
      expect(convertedJson['name'], 'كريم حسن');
      expect(convertedJson['rating'], 4.0);
      expect(convertedJson['userId'], 'usr_99');
    });

    test('should map ReviewModel to and from ReviewEntity accurately', () {
      // Arrange
      const entity = ReviewEntity(
        name: 'نور أحمد',
        description: 'فاكهة طازجة ونظيفة',
        rating: 4.8,
        date: '2026-09-21',
        image: 'img.png',
        userId: 'usr_77',
      );

      // Act
      final model = ReviewModel.fromEntity(entity);
      final mappedEntity = model.toEntity();

      // Assert
      expect(model.name, entity.name);
      expect(model.rating, entity.rating);
      expect(model.userId, entity.userId);
      expect(mappedEntity.name, entity.name);
      expect(mappedEntity.rating, entity.rating);
      expect(mappedEntity.userId, entity.userId);
    });
  });
}
