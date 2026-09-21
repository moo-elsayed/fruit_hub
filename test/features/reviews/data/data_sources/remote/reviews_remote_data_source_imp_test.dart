import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/models/review_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/reviews/data/data_sources/remote/reviews_remote_data_source_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late ReviewsRemoteDataSourceImp sut;

  const tUserId = 'user_test_123';
  const tProductCode = 'FRUIT_APPLE_01';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn(tUserId);
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

    sut = ReviewsRemoteDataSourceImp(
      firestore: fakeFirestore,
      auth: mockFirebaseAuth,
    );
  });

  group('checkUserPurchasedProduct', () {
    test(
      'should return NetworkSuccess with false when currentUser is null',
      () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = await sut.checkUserPurchasedProduct(
          productCode: tProductCode,
        );

        // Assert
        expect(result, isA<NetworkSuccess<bool>>());
        final isPurchased = (result as NetworkSuccess<bool>).data;
        expect(isPurchased, isFalse);
      },
    );

    test(
      'should return NetworkSuccess with true when user has a delivered order containing the product',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.ordersCollection)
            .add({
              'uId': tUserId,
              'status': 'delivered',
              'orderItems': [
                {'code': tProductCode, 'name': 'تفاح'},
              ],
            });

        // Act
        final result = await sut.checkUserPurchasedProduct(
          productCode: tProductCode,
        );

        // Assert
        expect(result, isA<NetworkSuccess<bool>>());
        final isPurchased = (result as NetworkSuccess<bool>).data;
        expect(isPurchased, isTrue);
      },
    );

    test(
      'should return NetworkSuccess with false when user order contains product but status is not delivered',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.ordersCollection)
            .add({
              'uId': tUserId,
              'status': 'pending',
              'orderItems': [
                {'code': tProductCode, 'name': 'تفاح'},
              ],
            });

        // Act
        final result = await sut.checkUserPurchasedProduct(
          productCode: tProductCode,
        );

        // Assert
        expect(result, isA<NetworkSuccess<bool>>());
        final isPurchased = (result as NetworkSuccess<bool>).data;
        expect(isPurchased, isFalse);
      },
    );

    test(
      'should return NetworkSuccess with false when user has delivered orders but none contain product',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.ordersCollection)
            .add({
              'uId': tUserId,
              'status': 'delivered',
              'orderItems': [
                {'code': 'DIFFERENT_PRODUCT_CODE', 'name': 'موز'},
              ],
            });

        // Act
        final result = await sut.checkUserPurchasedProduct(
          productCode: tProductCode,
        );

        // Assert
        expect(result, isA<NetworkSuccess<bool>>());
        final isPurchased = (result as NetworkSuccess<bool>).data;
        expect(isPurchased, isFalse);
      },
    );

    test(
      'should return NetworkSuccess with false when orders collection has no orders for the user',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.ordersCollection)
            .add({
              'uId': 'different_user_id',
              'status': 'delivered',
              'orderItems': [
                {'code': tProductCode, 'name': 'تفاح'},
              ],
            });

        // Act
        final result = await sut.checkUserPurchasedProduct(
          productCode: tProductCode,
        );

        // Assert
        expect(result, isA<NetworkSuccess<bool>>());
        final isPurchased = (result as NetworkSuccess<bool>).data;
        expect(isPurchased, isFalse);
      },
    );

    test(
      'should return NetworkFailure with ServerFailure when document data has invalid format causing exception',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.ordersCollection)
            .add({
              'uId': tUserId,
              'status': 'delivered',
              'orderItems': 'invalid_items_string',
            });

        // Act
        final result = await sut.checkUserPurchasedProduct(
          productCode: tProductCode,
        );

        // Assert
        expect(result, isA<NetworkFailure<bool>>());
        final failure = (result as NetworkFailure<bool>).failure;
        expect(failure.error, AppStrings.unexpectedError);
      },
    );
  });

  group('addReview', () {
    const tReviewModel = ReviewModel(
      name: 'علي',
      image: 'assets/images/ali.png',
      description: 'طازج ولذيذ جداً',
      date: '2026-09-20',
      rating: 5.0,
      userId: tUserId,
    );

    final Map<String, dynamic> tInitialProductData = {
      'name': 'تفاح أحمر',
      'description': 'تفاح طازج',
      'price': 25.0,
      'imagePath': 'assets/images/apple.png',
      'code': tProductCode,
      'isFeatured': true,
      'avgRating': 4.0,
      'ratingCount': 1,
      'isOrganic': true,
      'daysUntilExpiration': 10,
      'weightInGrams': 500,
      'numberOfCalories': 52,
      'sellingCount': 100,
      'reviews': [
        {
          'name': 'محمد',
          'image': 'assets/images/mohamed.png',
          'description': 'جيد',
          'date': '2026-09-01',
          'rating': 4.0,
          'userId': 'user_prev',
        },
      ],
    };

    test(
      'should return NetworkSuccess and update product document with new review, avgRating, and ratingCount when product exists',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .doc(tProductCode)
            .set(tInitialProductData);

        // Act
        final result = await sut.addReview(
          productCode: tProductCode,
          reviewModel: tReviewModel,
        );

        // Assert
        expect(result, isA<NetworkSuccess<void>>());

        final docSnapshot = await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .doc(tProductCode)
            .get();

        expect(docSnapshot.exists, isTrue);
        final data = docSnapshot.data()!;
        expect(data['ratingCount'], 2);
        expect(data['avgRating'], 4.5);

        final reviews = data['reviews'] as List<dynamic>;
        expect(reviews, hasLength(2));
        final addedReview = reviews.last as Map<String, dynamic>;
        expect(addedReview['name'], tReviewModel.name);
        expect(addedReview['description'], tReviewModel.description);
        expect(addedReview['rating'], 5.0);
        expect(addedReview['userId'], tUserId);
      },
    );

    test(
      'should correctly calculate avgRating with rounded single decimal place when average is recurring decimal',
      () async {
        // Arrange - initial product with 2 reviews of 4.0 each (total 8.0)
        final dataWithTwoReviews = Map<String, dynamic>.from(tInitialProductData);
        dataWithTwoReviews['ratingCount'] = 2;
        dataWithTwoReviews['avgRating'] = 4.0;
        dataWithTwoReviews['reviews'] = [
          {
            'name': 'محمد',
            'image': 'assets/images/mohamed.png',
            'description': 'جيد',
            'date': '2026-09-01',
            'rating': 4.0,
            'userId': 'user_1',
          },
          {
            'name': 'خالد',
            'image': 'assets/images/khaled.png',
            'description': 'جيد جداً',
            'date': '2026-09-05',
            'rating': 4.0,
            'userId': 'user_2',
          },
        ];

        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .doc(tProductCode)
            .set(dataWithTwoReviews);

        // Adding 5.0 rating -> total = 13.0 / 3 = 4.333333333333333 -> rounded to 4.3
        // Act
        final result = await sut.addReview(
          productCode: tProductCode,
          reviewModel: tReviewModel,
        );

        // Assert
        expect(result, isA<NetworkSuccess<void>>());

        final docSnapshot = await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .doc(tProductCode)
            .get();

        final data = docSnapshot.data()!;
        expect(data['ratingCount'], 3);
        expect(data['avgRating'], 4.3);
      },
    );

    test(
      'should return NetworkFailure with notFoundError when product document does not exist',
      () async {
        // Arrange - document does not exist

        // Act
        final result = await sut.addReview(
          productCode: 'NON_EXISTENT_PRODUCT_CODE',
          reviewModel: tReviewModel,
        );

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure.error, AppStrings.notFoundError);
      },
    );

    test(
      'should return NetworkFailure with unexpectedError when product document has malformed data causing exception',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.productsCollection)
            .doc(tProductCode)
            .set({
              'name': 'تفاح',
              'reviews': 'invalid_reviews_string',
            });

        // Act
        final result = await sut.addReview(
          productCode: tProductCode,
          reviewModel: tReviewModel,
        );

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure.error, AppStrings.unexpectedError);
      },
    );
  });

  group('Model and Entity Mappings', () {
    test(
      'ReviewModel toEntity and fromEntity should map all properties correctly',
      () {
        // Arrange
        const entity = ReviewEntity(
          name: 'ياسمين',
          image: 'assets/images/yasmin.png',
          description: 'تجربة رائعة',
          date: '2026-09-18',
          rating: 4.8,
          userId: 'user_yasmin',
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
          'name': 'هند',
          'description': 'فاكهة طازجة ولذيذة',
          'rating': 4.5,
          'date': '2026-09-19',
          'image': 'assets/images/hind.png',
          'userId': 'user_hind',
        };

        // Act
        final model = ReviewModel.fromJson(jsonWithUser);
        final outputJson = model.toJson();

        // Assert
        expect(model.name, 'هند');
        expect(model.description, 'فاكهة طازجة ولذيذة');
        expect(model.rating, 4.5);
        expect(model.date, '2026-09-19');
        expect(model.image, 'assets/images/hind.png');
        expect(model.userId, 'user_hind');
        expect(outputJson, equals(jsonWithUser));

        // Without userId
        const modelWithoutUser = ReviewModel(
          name: 'زائر',
          image: '',
          description: 'بدون معرف مستخدم',
          date: '2026-09-20',
          rating: 3.0,
        );
        expect(modelWithoutUser.toJson().containsKey('userId'), isFalse);
      },
    );

    test(
      'ReviewModel fromJson should handle uId alias fallback and missing/null fields with default values',
      () {
        // Arrange
        final jsonWithUidAlias = {
          'rating': 4, // int coerced to double
          'uId': 'alias_user_id',
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
        expect(model.userId, 'alias_user_id');
      },
    );

    test(
      'FruitModel toEntity should map all properties correctly to FruitEntity including nested reviews',
      () {
        // Arrange
        const reviewModel = ReviewModel(
          name: 'أحمد',
          image: 'assets/images/ahmed.png',
          description: 'ممتاز',
          date: '2026-09-15',
          rating: 4.5,
          userId: 'user_ahmed',
        );

        final fruitModel = FruitModel(
          name: 'برتقال',
          description: 'برتقال سكري',
          price: 18.0,
          imagePath: 'assets/images/orange.png',
          code: 'ORANGE_01',
          isFeatured: true,
          avgRating: 4.5,
          ratingCount: 10,
          isOrganic: true,
          daysUntilExpiration: 15,
          weightInGrams: 1000,
          numberOfCalories: 47,
          sellingCount: 120,
          reviews: const [reviewModel],
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
        expect(entity.reviews.first.rating, reviewModel.rating);
        expect(entity.reviews.first.userId, reviewModel.userId);
      },
    );

    test(
      'FruitModel fromJson should parse complete json correctly with fallbacks and numeric type coercion',
      () {
        // Arrange
        final json = {
          'price': 15, // int coerced to double
          'unitAmount': 400, // fallback for weightInGrams
        };

        // Act
        final model = FruitModel.fromJson(json);

        // Assert
        expect(model.name, '');
        expect(model.description, '');
        expect(model.price, 15.0);
        expect(model.price, isA<double>());
        expect(model.weightInGrams, 400);
        expect(model.reviews, isEmpty);
      },
    );
  });
}
