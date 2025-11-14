import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
import 'package:fruit_hub/features/cart/data/data_sources/cart_remote_data_source_imp.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
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
  late CartItemEntity tCartItemEntity;

  const tUserId = 'test_user_id_123';
  const tProductId = 'apple_red';
  const tPath = 'users/$tUserId/cart';
  const tNewQuantity = 5;
  final tUpdateDataMap = {'quantity': tNewQuantity};

  const tRawData = [
    {
      'fruitCode': 'apple_red',
      'productName': 'Apple',
      'imageUrl': 'test_image_url',
      'quantity': 2,
      'price': 10.0,
    },
    {
      'fruitCode': 'banana_yellow',
      'productName': 'Banana',
      'imageUrl': 'test_image_url',
      'quantity': 3,
      'price': 15.0,
    },
  ];

  final tFirebaseException = FirebaseException(
    plugin: 'firestore',
    code: 'permission-denied',
    message: 'Permission denied on collection.',
  );

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    tFruitEntity = MockFruitEntity();
    sut = CartRemoteDataSourceImp(mockDatabaseService, mockFirebaseAuth);
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(tUserId);
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(tUserId);
    when(() => tFruitEntity.price).thenReturn(10.0);
    when(() => tFruitEntity.code).thenReturn(tProductId);
    when(() => tFruitEntity.name).thenReturn('Apple');
    when(() => tFruitEntity.imagePath).thenReturn('test_image_url');
    tCartItemEntity = CartItemEntity(fruitEntity: tFruitEntity, quantity: 2);
  });


  group('addItemToCart', () {
    test(
      'should return NetworkSuccess when user is logged in and database call is successful',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.addData(
            path: tPath,
            data: any(named: 'data'),
            docId: tProductId,
          ),
        ).thenAnswer((_) async => Future.value());
        // Act
        final result = await sut.addItemToCart(tCartItemEntity);
        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockDatabaseService.addData(
            path: tPath,
            docId: tProductId,
            data: any(named: 'data'),
          ),
        );
        verify(() => mockFirebaseAuth.currentUser);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test('should return NetworkFailure when user is not logged in', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      // Act
      final result = await sut.addItemToCart(tCartItemEntity);
      // Assert
      expect(result, isA<NetworkFailure<void>>());
      expect(getErrorMessage(result), contains("user_not_logged_in"));
      verify(() => mockFirebaseAuth.currentUser);
      verifyNoMoreInteractions(mockDatabaseService);
    });

    test('should return NetworkFailure when database call fails', () async {
      // Arrange
      when(
        () => mockDatabaseService.addData(
          path: tPath,
          data: any(named: 'data'),
          docId: tProductId,
        ),
      ).thenThrow(tFirebaseException);
      // Act
      final result = await sut.addItemToCart(tCartItemEntity);
      // Assert
      expect(result, isA<NetworkFailure<void>>());
      expect(getErrorMessage(result), contains("permission-denied"));
      verify(
        () => mockDatabaseService.addData(
          path: tPath,
          docId: tProductId,
          data: any(named: 'data'),
        ),
      );
      verify(() => mockFirebaseAuth.currentUser);
      verifyNoMoreInteractions(mockDatabaseService);
    });
  });


  group('removeItemFromCart', () {
    test(
      'should return NetworkSuccess when user is logged in and database call is successful',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.deleteData(
            path: tPath,
            documentId: tProductId,
          ),
        ).thenAnswer((_) async => Future.value());
        // Act
        final result = await sut.removeItemFromCart(tProductId);
        // Assert
        expect(result, isA<NetworkSuccess<void>>());
        verify(
          () => mockDatabaseService.deleteData(
            path: tPath,
            documentId: tProductId,
          ),
        );
        verify(() => mockFirebaseAuth.currentUser);
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
      verify(() => mockFirebaseAuth.currentUser);
      verifyNoMoreInteractions(mockDatabaseService);
    });

    test('should return NetworkFailure when database call fails', () async {
      // Arrange
      when(
        () =>
            mockDatabaseService.deleteData(path: tPath, documentId: tProductId),
      ).thenThrow(tFirebaseException);
      // Act
      final result = await sut.removeItemFromCart(tProductId);
      // Assert
      expect(result, isA<NetworkFailure<void>>());
      expect(getErrorMessage(result), contains("permission-denied"));
      verify(
        () =>
            mockDatabaseService.deleteData(path: tPath, documentId: tProductId),
      );
      verify(() => mockFirebaseAuth.currentUser);
      verifyNoMoreInteractions(mockDatabaseService);
    });
  });

  group('getCartItems', () {
    test(
      'should return NetworkSuccess with cart items when user is logged in and database call is successful',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.getAllData(tPath),
        ).thenAnswer((_) async => tRawData);
        // Act
        final result = await sut.getCartItems();
        // Assert
        expect(result, isA<NetworkSuccess<List<CartItemEntity>>>());
        final data = (result as NetworkSuccess).data;
        expect(data, isA<List<CartItemEntity>>());
        expect(data.length, tRawData.length);
        verify(() => mockDatabaseService.getAllData(tPath));
        verify(() => mockFirebaseAuth.currentUser);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test('should return NetworkFailure when user is not logged in', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      // Act
      final result = await sut.getCartItems();
      // Assert
      expect(result, isA<NetworkFailure<List<CartItemEntity>>>());
      expect(getErrorMessage(result), contains("user_not_logged_in"));
      verify(() => mockFirebaseAuth.currentUser);
      verifyNoMoreInteractions(mockDatabaseService);
    });

    test('should return NetworkFailure when database call fails', () async {
      // Arrange
      when(
        () => mockDatabaseService.getAllData(tPath),
      ).thenThrow(tFirebaseException);
      // Act
      final result = await sut.getCartItems();
      // Assert
      expect(result, isA<NetworkFailure<List<CartItemEntity>>>());
      expect(getErrorMessage(result), contains("permission-denied"));
      verify(() => mockDatabaseService.getAllData(tPath));
      verify(() => mockFirebaseAuth.currentUser);
      verifyNoMoreInteractions(mockDatabaseService);
    });
  });

  group('updateItemQuantity', () {
    test(
      'should return NetworkSuccess when user is logged in and database update is successful',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.updateData(
            path: tPath,
            documentId: tProductId,
            data: tUpdateDataMap,
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
          () => mockDatabaseService.updateData(
            path: tPath,
            documentId: tProductId,
            data: tUpdateDataMap,
          ),
        );
        verify(() => mockFirebaseAuth.currentUser);
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
      verify(() => mockFirebaseAuth.currentUser);
      verifyNoMoreInteractions(mockDatabaseService);
    });

    test('should return NetworkFailure when database update fails', () async {
      // Arrange
      when(
        () => mockDatabaseService.updateData(
          path: tPath,
          documentId: tProductId,
          data: tUpdateDataMap,
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
          path: tPath,
          documentId: tProductId,
          data: tUpdateDataMap,
        ),
      );
      verify(() => mockFirebaseAuth.currentUser);
      verifyNoMoreInteractions(mockDatabaseService);
    });
  });
}
