import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
import 'package:fruit_hub/core/services/database/query_parameters.dart';
import 'package:fruit_hub/features/cart/data/data_sources/remote/cart_remote_data_source_imp.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFruitEntity extends Mock implements FruitEntity {}

void main() {
  late CartRemoteDataSourceImp sut;
  late MockDatabaseService mockDatabaseService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late MockFruitEntity tFruitEntity;

  const tUserId = 'test_user_id_123';
  const keyGetUserData = 'users';
  const keyUpdateUserData = 'users';
  const tProductId = 'apple_red';

  final tFirebaseException = FirebaseException(
    plugin: 'firestore',
    code: 'permission-denied',
    message: 'Permission denied on collection.',
  );

  setUpAll(() {
    registerFallbackValue(const QueryParameters());
  });

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    tFruitEntity = MockFruitEntity();
    sut = CartRemoteDataSourceImp(mockDatabaseService, mockFirebaseAuth);
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(tUserId);
    when(() => tFruitEntity.price).thenReturn(10.0);
    when(() => tFruitEntity.code).thenReturn(tProductId);
    when(() => tFruitEntity.name).thenReturn('Apple');
    when(() => tFruitEntity.imagePath).thenReturn('test_image_url');
  });

  group('addItemToCart', () {
    test(
      'should return NetworkSuccess when adding a NEW item to cart (first time)',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.getData(
            path: keyGetUserData,
            documentId: tUserId,
          ),
        ).thenAnswer((_) async => {});
        when(
          () => mockDatabaseService.updateData(
            path: keyUpdateUserData,
            documentId: tUserId,
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => Future.value());
        // Act
        final result = await sut.addItemToCart(tProductId);
        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockDatabaseService.getData(
            path: any(named: 'path'),
            documentId: tUserId,
          ),
        ).called(1);
        verify(
          () => mockDatabaseService.updateData(
            path: keyUpdateUserData,
            documentId: tUserId,
            data: {
              'cartItems': [
                {'fruitCode': tProductId, 'quantity': 1},
              ],
            },
          ),
        ).called(1);
        verify(() => mockFirebaseAuth.currentUser).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test(
      'should return NetworkSuccess and INCREMENT quantity when item already exists',
      () async {
        // Arrange
        final existingData = {
          'cartItems': [
            {'fruitCode': tProductId, 'quantity': 1},
          ],
        };
        when(
          () => mockDatabaseService.getData(
            path: keyGetUserData,
            documentId: tUserId,
          ),
        ).thenAnswer((_) async => existingData);
        when(
          () => mockDatabaseService.updateData(
            path: keyUpdateUserData,
            documentId: tUserId,
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => Future.value);
        // Act
        final result = await sut.addItemToCart(tProductId);
        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockDatabaseService.getData(
            path: keyGetUserData,
            documentId: tUserId,
          ),
        ).called(1);
        verify(
          () => mockDatabaseService.updateData(
            path: keyUpdateUserData,
            documentId: tUserId,
            data: {
              'cartItems': [
                {'fruitCode': tProductId, 'quantity': 2},
              ],
            },
          ),
        ).called(1);
        verify(() => mockFirebaseAuth.currentUser).called(1);
      },
    );
    test('should return NetworkFailure when user is not logged in', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      // Act
      final result = await sut.addItemToCart(tProductId);
      // Assert
      expect(result, isA<NetworkFailure<void>>());
      expect(getErrorMessage(result), contains("user_not_logged_in"));
      verify(() => mockFirebaseAuth.currentUser).called(1);
      verifyNoMoreInteractions(mockDatabaseService);
    });

    test('should return NetworkFailure when database getData fails', () async {
      // Arrange
      when(
        () => mockDatabaseService.getData(
          path: any(named: 'path'),
          documentId: tUserId,
        ),
      ).thenThrow(tFirebaseException);
      // Act
      final result = await sut.addItemToCart(tProductId);
      // Assert
      expect(result, isA<NetworkFailure<void>>());
      expect(getErrorMessage(result), contains("permission-denied"));
      verify(
        () => mockDatabaseService.getData(
          path: any(named: 'path'),
          documentId: tUserId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockDatabaseService);
    });

    test(
      'should return NetworkFailure when database updateData fails',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.getData(
            path: any(named: 'path'),
            documentId: tUserId,
          ),
        ).thenAnswer((_) async => {});
        when(
          () => mockDatabaseService.updateData(
            path: keyUpdateUserData,
            documentId: tUserId,
            data: any(named: 'data'),
          ),
        ).thenThrow(tFirebaseException);
        // Act
        final result = await sut.addItemToCart(tProductId);
        // Assert
        expect(result, isA<NetworkFailure<void>>());
        expect(getErrorMessage(result), contains("permission-denied"));
        verify(
          () => mockDatabaseService.updateData(
            path: any(named: 'path'),
            documentId: tUserId,
            data: any(named: 'data'),
          ),
        ).called(1);
      },
    );
  });

  group('removeItemFromCart', () {
    test(
      'should return NetworkSuccess and update the list via updateData excluding the removed item',
      () async {
        // Arrange
        final initialData = {
          'cartItems': [
            {'fruitCode': tProductId, 'quantity': 2},
            {'fruitCode': 'banana_yellow', 'quantity': 5},
          ],
        };
        when(
          () => mockDatabaseService.getData(
            path: keyGetUserData,
            documentId: tUserId,
          ),
        ).thenAnswer((_) async => initialData);
        when(
          () => mockDatabaseService.updateData(
            path: keyUpdateUserData,
            documentId: tUserId,
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => Future.value());
        // Act
        final result = await sut.removeItemFromCart(tProductId);
        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockDatabaseService.getData(
            path: keyGetUserData,
            documentId: tUserId,
          ),
        ).called(1);
        verify(
          () => mockDatabaseService.updateData(
            path: keyUpdateUserData,
            documentId: tUserId,
            data: {
              'cartItems': [
                {'fruitCode': 'banana_yellow', 'quantity': 5},
              ],
            },
          ),
        ).called(1);
        verify(() => mockFirebaseAuth.currentUser).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test('should return NetworkFailure when user is not logged in', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      // Act
      final result = await sut.removeItemFromCart(tProductId);
      // Assert
      expect(result, isA<NetworkFailure<void>>());
      expect(getErrorMessage(result), contains("user_not_logged_in"));
      verify(() => mockFirebaseAuth.currentUser).called(1);
      verifyNoMoreInteractions(mockDatabaseService);
    });

    test('should return NetworkFailure when getData fails', () async {
      // Arrange
      when(
        () => mockDatabaseService.getData(
          path: any(named: 'path'),
          documentId: tUserId,
        ),
      ).thenThrow(tFirebaseException);
      // Act
      final result = await sut.removeItemFromCart(tProductId);
      // Assert
      expect(result, isA<NetworkFailure<void>>());
      expect(getErrorMessage(result), contains("permission-denied"));
      verify(
        () => mockDatabaseService.getData(
          path: any(named: 'path'),
          documentId: tUserId,
        ),
      ).called(1);
      verifyNever(
        () => mockDatabaseService.updateData(
          path: any(named: 'path'),
          documentId: any(named: 'documentId'),
          data: any(named: 'data'),
        ),
      );
    });

    test('should return NetworkFailure when updateData fails', () async {
      // Arrange
      when(
        () => mockDatabaseService.getData(
          path: any(named: 'path'),
          documentId: tUserId,
        ),
      ).thenAnswer((_) async => {});
      when(
        () => mockDatabaseService.updateData(
          path: keyUpdateUserData,
          documentId: tUserId,
          data: any(named: 'data'),
        ),
      ).thenThrow(tFirebaseException);
      // Act
      final result = await sut.removeItemFromCart(tProductId);
      // Assert
      expect(result, isA<NetworkFailure<void>>());
      expect(getErrorMessage(result), contains("permission-denied"));
      verify(
        () => mockDatabaseService.updateData(
          path: keyUpdateUserData,
          data: any(named: 'data'),
          documentId: tUserId,
        ),
      ).called(1);
      verify(
        () => mockDatabaseService.getData(
          path: any(named: 'path'),
          documentId: tUserId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockDatabaseService);
    });
  });

  group('getProductsInCart', () {
    final tCartItemsInput = [
      {'fruitCode': 'apple_red', 'quantity': 2},
      {'fruitCode': 'banana_yellow', 'quantity': 5},
    ];

    final tProductsDbResponse = [
      {
        'imagePath': 'image_path_1',
        'name': 'Apple',
        'code': 'apple_red',
        'description': 'A sweet, red apple.',
        'price': 1.50,
        'isFeatured': true,
        'isOrganic': true,
        'daysUntilExpiration': 7,
        'numberOfCalories': 52,
        'unitAmount': 1,
        'ratingCount': 100,
        'sellingCount': 500,
        'avgRating': 4.5,
        'reviews': [],
      },
      {
        'imagePath': 'image_path_2',
        'name': 'Banana',
        'code': 'banana_yellow',
        'description': 'A ripe, yellow banana.',
        'price': 0.75,
        'isFeatured': false,
        'isOrganic': false,
        'daysUntilExpiration': 5,
        'numberOfCalories': 89,
        'unitAmount': 1,
        'ratingCount': 150,
        'sellingCount': 800,
        'avgRating': 4.7,
        'reviews': [],
      },
    ];

    test(
      'should return NetworkSuccess with empty list immediately if cartItems input is empty (No DB call)',
      () async {
        // Arrange
        // Act
        final result = await sut.getProductsInCart([]);
        // Assert
        expect(result, isA<NetworkSuccess<List<CartItemEntity>>>());
        expect((result as NetworkSuccess<List<CartItemEntity>>).data, isEmpty);
        verifyNever(
          () => mockDatabaseService.queryData(
            path: any(named: 'path'),
            query: any(named: 'query'),
          ),
        );
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test(
      'should return NetworkSuccess with mapped CartItemEntities when DB query is successful',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.queryData(
            path: any(named: 'path'),
            query: any(named: 'query'),
          ),
        ).thenAnswer((_) async => tProductsDbResponse);
        // Act
        final result = await sut.getProductsInCart(tCartItemsInput);
        // Assert
        expect(result, isA<NetworkSuccess<List<CartItemEntity>>>());
        expect(
          (result as NetworkSuccess<List<CartItemEntity>>).data!.length,
          2,
        );
        expect((result).data![0].fruitEntity.code, 'apple_red');
        expect((result).data![0].quantity, 2);
        expect((result).data![1].fruitEntity.code, 'banana_yellow');
        expect((result).data![1].quantity, 5);
        verify(
          () => mockDatabaseService.queryData(
            path: any(named: 'path'),
            query: any(named: 'query'),
          ),
        ).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test(
      'should return NetworkFailure when database queryData throws exception',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.queryData(
            path: any(named: 'path'),
            query: any(named: 'query'),
          ),
        ).thenThrow(tFirebaseException);
        // Act
        final result = await sut.getProductsInCart(tCartItemsInput);
        // Assert
        expect(result, isA<NetworkFailure<List<CartItemEntity>>>());
        expect(getErrorMessage(result), contains("permission-denied"));
        verify(
          () => mockDatabaseService.queryData(
            path: any(named: 'path'),
            query: any(named: 'query'),
          ),
        ).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );
  });

  group('updateItemQuantity', () {
    const tNewQuantity = 5;
    test(
      'should return NetworkSuccess and update database with the specific new quantity',
      () async {
        // Arrange
        final initialData = {
          'cartItems': [
            {'fruitCode': tProductId, 'quantity': 1},
            {'fruitCode': 'banana_yellow', 'quantity': 10},
          ],
        };

        when(
          () => mockDatabaseService.getData(
            path: keyGetUserData,
            documentId: tUserId,
          ),
        ).thenAnswer((_) async => initialData);

        when(
          () => mockDatabaseService.updateData(
            path: keyUpdateUserData,
            documentId: tUserId,
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => Future.value());
        // Act
        final result = await sut.updateItemQuantity(
          productId: tProductId,
          newQuantity: tNewQuantity,
        );
        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockDatabaseService.getData(
            path: keyGetUserData,
            documentId: tUserId,
          ),
        ).called(1);
        verify(
          () => mockDatabaseService.updateData(
            path: keyUpdateUserData,
            documentId: tUserId,
            data: {
              'cartItems': [
                {'fruitCode': tProductId, 'quantity': tNewQuantity},
                {'fruitCode': 'banana_yellow', 'quantity': 10},
              ],
            },
          ),
        ).called(1);
        verify(() => mockFirebaseAuth.currentUser).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test('should return NetworkFailure when user is not logged in', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      // Act
      final result = await sut.updateItemQuantity(
        productId: tProductId,
        newQuantity: tNewQuantity,
      );
      // Assert
      expect(result, isA<NetworkFailure<void>>());
      expect(getErrorMessage(result), contains("user_not_logged_in"));
      verify(() => mockFirebaseAuth.currentUser).called(1);
      verifyNoMoreInteractions(mockDatabaseService);
    });

    test('should return NetworkFailure when getData fails', () async {
      // Arrange
      when(
        () => mockDatabaseService.getData(
          path: any(named: 'path'),
          documentId: tUserId,
        ),
      ).thenThrow(tFirebaseException);
      // Act
      final result = await sut.updateItemQuantity(
        productId: tProductId,
        newQuantity: tNewQuantity,
      );
      // Assert
      expect(result, isA<NetworkFailure<void>>());
      expect(getErrorMessage(result), contains("permission-denied"));
      verify(
        () => mockDatabaseService.getData(
          path: any(named: 'path'),
          documentId: tUserId,
        ),
      ).called(1);
      verifyNever(
        () => mockDatabaseService.updateData(
          path: any(named: 'path'),
          documentId: any(named: 'documentId'),
          data: any(named: 'data'),
        ),
      );
    });

    test('should return NetworkFailure when updateData fails', () async {
      // Arrange
      when(
        () => mockDatabaseService.getData(
          path: any(named: 'path'),
          documentId: tUserId,
        ),
      ).thenAnswer((_) async => {});
      when(
        () => mockDatabaseService.updateData(
          path: keyUpdateUserData,
          documentId: tUserId,
          data: any(named: 'data'),
        ),
      ).thenThrow(tFirebaseException);
      // Act
      final result = await sut.updateItemQuantity(
        productId: tProductId,
        newQuantity: tNewQuantity,
      );
      // Assert
      expect(result, isA<NetworkFailure<void>>());
      expect(getErrorMessage(result), contains("permission-denied"));
      verify(
        () => mockDatabaseService.updateData(
          path: keyUpdateUserData,
          data: any(named: 'data'),
          documentId: tUserId,
        ),
      ).called(1);
      verify(
        () => mockDatabaseService.getData(
          path: any(named: 'path'),
          documentId: tUserId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockDatabaseService);
    });
  });

  group('getCartItems', () {
    final cartItems = {
      'cartItems': [
        {'fruitCode': tProductId, 'quantity': 1},
        {'fruitCode': 'banana_yellow', 'quantity': 10},
      ],
    };

    test('should return NetworkSuccess with cartItems', () async {
      // Arrange
      when(
        () => mockDatabaseService.getData(
          path: keyGetUserData,
          documentId: tUserId,
        ),
      ).thenAnswer((_) async => cartItems);
      // Act
      final result = await sut.getCartItems();
      // Assert
      expect(result, isA<NetworkSuccess<List<Map<String, dynamic>>>>());
      expect(
        (result as NetworkSuccess<List<Map<String, dynamic>>>).data,
        cartItems['cartItems'],
      );
      verify(
        () => mockDatabaseService.getData(
          path: keyGetUserData,
          documentId: tUserId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockDatabaseService);
    });

    test('should return NetworkFailure when user is not logged in', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      // Act
      final result = await sut.getCartItems();
      // Assert
      expect(result, isA<NetworkFailure<List<Map<String, dynamic>>>>());
      expect(getErrorMessage(result), contains("user_not_logged_in"));
      verify(() => mockFirebaseAuth.currentUser).called(1);
      verifyNoMoreInteractions(mockDatabaseService);
    });

    test('should return NetworkFailure when getData fails', () async {
      // Arrange
      when(
        () => mockDatabaseService.getData(
          path: any(named: 'path'),
          documentId: tUserId,
        ),
      ).thenThrow(tFirebaseException);
      // Act
      final result = await sut.getCartItems();
      // Assert
      expect(result, isA<NetworkFailure<List<Map<String, dynamic>>>>());
      expect(getErrorMessage(result), contains("permission-denied"));
      verify(
        () => mockDatabaseService.getData(
          path: any(named: 'path'),
          documentId: tUserId,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockDatabaseService);
    });
  });
}
