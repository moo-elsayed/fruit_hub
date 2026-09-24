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
import 'package:fruit_hub/features/favorites/data/data_sources/remote/favorites_remote_data_source_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late FavoritesRemoteDataSourceImp sut;

  const tUserId = 'user_fav_123';
  const tProductId1 = 'prod_apple_01';
  const tProductId2 = 'prod_banana_02';

  final Map<String, dynamic> tFruitJson1 = {
    'name': 'تفاح أحمر',
    'description': 'تفاح أحمر طازج ولذيذ',
    'price': 25.0,
    'imagePath': 'assets/images/red_apple.png',
    'code': tProductId1,
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
    'code': tProductId2,
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

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(tUserId);

    sut = FavoritesRemoteDataSourceImp(
      firestore: fakeFirestore,
      auth: mockFirebaseAuth,
    );
  });

  group('addItemToFavorites', () {
    test('should return NetworkSuccess and append productId to favoriteIds when user is authenticated', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            'email': 'user@example.com',
            BackendEndpoints.favoriteIdsField: [tProductId1],
          });

      // Act
      final result = await sut.addItemToFavorites(tProductId2);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      final doc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .get();
      final data = doc.data()!;
      expect(data['email'], 'user@example.com');
      final favoriteIds = List<String>.from(
        data[BackendEndpoints.favoriteIdsField],
      );
      expect(favoriteIds, containsAll([tProductId1, tProductId2]));
      expect(favoriteIds, hasLength(2));
    });

    test(
      'should not duplicate productId when productId is already in favorites',
      () async {
        // Arrange
        await fakeFirestore
            .collection(BackendEndpoints.usersCollection)
            .doc(tUserId)
            .set({
              'email': 'user@example.com',
              BackendEndpoints.favoriteIdsField: [tProductId1],
            });

        // Act
        final result = await sut.addItemToFavorites(tProductId1);

        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        final doc = await fakeFirestore
            .collection(BackendEndpoints.usersCollection)
            .doc(tUserId)
            .get();
        final favoriteIds = List<String>.from(
          doc.data()![BackendEndpoints.favoriteIdsField],
        );
        expect(favoriteIds, [tProductId1]);
      },
    );

    test('should return NetworkFailure with userNotFound error when currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await sut.addItemToFavorites(tProductId1);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.userNotFound);
    });

    test('should return NetworkFailure when user document does not exist in firestore', () async {
      // Arrange - document does not exist in firestore

      // Act
      final result = await sut.addItemToFavorites(tProductId1);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, isNotEmpty);
    });
  });

  group('removeItemFromFavorites', () {
    test('should return NetworkSuccess and remove productId from favoriteIds while preserving unrelated fields', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            'name': 'محمد علي',
            'email': 'mohamed@example.com',
            BackendEndpoints.favoriteIdsField: [tProductId1, tProductId2],
          });

      // Act
      final result = await sut.removeItemFromFavorites(tProductId1);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      final doc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .get();
      final data = doc.data()!;
      expect(data['name'], 'محمد علي');
      expect(data['email'], 'mohamed@example.com');
      final favoriteIds = List<String>.from(
        data[BackendEndpoints.favoriteIdsField],
      );
      expect(favoriteIds, [tProductId2]);
    });

    test('should return NetworkSuccess and leave list unchanged when removing non-existing productId', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            BackendEndpoints.favoriteIdsField: [tProductId1],
          });

      // Act
      final result = await sut.removeItemFromFavorites('non_existing_product');

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      final doc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .get();
      final favoriteIds = List<String>.from(
        doc.data()![BackendEndpoints.favoriteIdsField],
      );
      expect(favoriteIds, [tProductId1]);
    });

    test('should return NetworkFailure with userNotFound error when currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await sut.removeItemFromFavorites(tProductId1);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.userNotFound);
    });

    test('should return NetworkFailure when user document does not exist in firestore', () async {
      // Arrange - document does not exist in firestore

      // Act
      final result = await sut.removeItemFromFavorites(tProductId1);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, isNotEmpty);
    });
  });

  group('getFavorites', () {
    test('should return NetworkSuccess with empty list when user document has no favorite ids', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({BackendEndpoints.favoriteIdsField: <String>[]});

      // Act
      final result = await sut.getFavorites();

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitModel>>>());
      final fruits = (result as NetworkSuccess<List<FruitModel>>).data;
      expect(fruits, isEmpty);
    });

    test('should return NetworkSuccess with empty list when user document does not exist in firestore', () async {
      // Arrange - no document for tUserId in firestore

      // Act
      final result = await sut.getFavorites();

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitModel>>>());
      final fruits = (result as NetworkSuccess<List<FruitModel>>).data;
      expect(fruits, isEmpty);
    });

    test('should return NetworkSuccess with matching FruitModel list when user has favorite ids and product documents exist', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            BackendEndpoints.favoriteIdsField: [tProductId1, tProductId2],
          });
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc(tProductId1)
          .set(tFruitJson1);
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc(tProductId2)
          .set(tFruitJson2);

      // Act
      final result = await sut.getFavorites();

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitModel>>>());
      final fruits = (result as NetworkSuccess<List<FruitModel>>).data!;
      expect(fruits, hasLength(2));
      final codes = fruits.map((f) => f.code).toList();
      expect(codes, containsAll([tProductId1, tProductId2]));
      final appleFruit = fruits.firstWhere((f) => f.code == tProductId1);
      expect(appleFruit.name, 'تفاح أحمر');
      expect(appleFruit.price, 25.0);
      expect(appleFruit.reviews, hasLength(1));
      expect(appleFruit.reviews.first.name, 'أحمد');
    });

    test('should return NetworkSuccess with only existing products when some favorite product documents do not exist', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            BackendEndpoints.favoriteIdsField: [tProductId1, 'non_existing_id'],
          });
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc(tProductId1)
          .set(tFruitJson1);

      // Act
      final result = await sut.getFavorites();

      // Assert
      expect(result, isA<NetworkSuccess<List<FruitModel>>>());
      final fruits = (result as NetworkSuccess<List<FruitModel>>).data!;
      expect(fruits, hasLength(1));
      expect(fruits.first.code, tProductId1);
    });

    test('should return NetworkFailure with userNotFound error when currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await sut.getFavorites();

      // Assert
      expect(result, isA<NetworkFailure<List<FruitModel>>>());
      final failure = (result as NetworkFailure<List<FruitModel>>).failure;
      expect(failure.error, AppStrings.userNotFound);
    });

    test('should return NetworkFailure with unexpectedError when product document data is corrupted', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            BackendEndpoints.favoriteIdsField: ['corrupt_product'],
          });
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc('corrupt_product')
          .set({'name': 'فاكهة تالفة', 'reviews': 'not_a_valid_list_reviews'});

      // Act
      final result = await sut.getFavorites();

      // Assert
      expect(result, isA<NetworkFailure<List<FruitModel>>>());
      final failure = (result as NetworkFailure<List<FruitModel>>).failure;
      expect(failure.error, AppStrings.unexpectedError);
    });
  });

  group('Model and Entity Mappings', () {
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

    test('ReviewModel fromJson should parse complete json with uId fallback and default values', () {
      // Arrange
      final jsonWithUId = {
        'name': 'علي',
        'description': 'ممتاز',
        'rating': 4,
        'date': '2026-09-01',
        'image': 'avatar.png',
        'uId': 'user_uId_1',
      };

      // Act
      final model = ReviewModel.fromJson(jsonWithUId);

      // Assert
      expect(model.name, 'علي');
      expect(model.description, 'ممتاز');
      expect(model.rating, 4.0);
      expect(model.date, '2026-09-01');
      expect(model.image, 'avatar.png');
      expect(model.userId, 'user_uId_1');
    });

    test('ReviewModel toJson should serialize correctly and conditionally include userId', () {
      // Arrange
      const reviewWithUserId = ReviewModel(
        name: 'علي',
        image: 'avatar.png',
        description: 'ممتاز',
        date: '2026-09-01',
        rating: 4.5,
        userId: 'user_123',
      );

      const reviewWithoutUserId = ReviewModel(
        name: 'علي',
        image: 'avatar.png',
        description: 'ممتاز',
        date: '2026-09-01',
        rating: 4.5,
      );

      // Act
      final jsonWithUser = reviewWithUserId.toJson();
      final jsonWithoutUser = reviewWithoutUserId.toJson();

      // Assert
      expect(jsonWithUser['name'], 'علي');
      expect(jsonWithUser['userId'], 'user_123');
      expect(jsonWithoutUser.containsKey('userId'), isFalse);
    });

    test(
      'ReviewModel toEntity and fromEntity should map all properties correctly',
      () {
        // Arrange
        const entity = ReviewEntity(
          name: 'منى',
          image: 'avatar2.png',
          description: 'رائع جداً',
          date: '2026-09-05',
          rating: 5.0,
          userId: 'user_999',
        );

        // Act
        final model = ReviewModel.fromEntity(entity);
        final mappedEntity = model.toEntity();

        // Assert
        expect(model.name, entity.name);
        expect(model.image, entity.image);
        expect(model.description, entity.description);
        expect(model.date, entity.date);
        expect(model.rating, entity.rating);
        expect(model.userId, entity.userId);

        expect(mappedEntity.name, entity.name);
        expect(mappedEntity.image, entity.image);
        expect(mappedEntity.description, entity.description);
        expect(mappedEntity.date, entity.date);
        expect(mappedEntity.rating, entity.rating);
        expect(mappedEntity.userId, entity.userId);
      },
    );
  });
}
