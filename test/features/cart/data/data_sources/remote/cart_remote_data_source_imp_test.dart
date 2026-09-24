import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/cart/data/data_sources/remote/cart_remote_data_source_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late CartRemoteDataSourceImp sut;

  const tUserId = 'user_cart_123';
  const tProductId1 = 'APPLE_01';
  const tProductId2 = 'BANANA_02';

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
    'reviews': <Map<String, dynamic>>[],
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

    sut = CartRemoteDataSourceImp(
      firestore: fakeFirestore,
      auth: mockFirebaseAuth,
    );
  });

  group('addItemToCart', () {
    test('should return NetworkFailure with userNotFound error when currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await sut.addItemToCart(tProductId1);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.userNotFound);
    });

    test('should return NetworkSuccess and add item with default quantity 1 when cart is empty and preserve existing user fields', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({'name': 'محمد أحمد', 'email': 'mohamed@example.com'});

      // Act
      final result = await sut.addItemToCart(tProductId1);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());

      final userDoc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .get();
      final userData = userDoc.data()!;
      expect(userData['name'], 'محمد أحمد');
      expect(userData['email'], 'mohamed@example.com');

      final cartItems = List<Map<String, dynamic>>.from(
        userData[BackendEndpoints.cartItemsField] as List,
      );
      expect(cartItems, hasLength(1));
      expect(cartItems.first['fruitCode'], tProductId1);
      expect(cartItems.first['quantity'], 1);
    });

    test('should return NetworkSuccess and add new item with specified quantity when item does not exist in cart', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            BackendEndpoints.cartItemsField: [
              {'fruitCode': tProductId1, 'quantity': 2},
            ],
          });

      // Act
      final result = await sut.addItemToCart(tProductId2, quantity: 4);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());

      final userDoc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .get();
      final cartItems = List<Map<String, dynamic>>.from(
        userDoc.data()![BackendEndpoints.cartItemsField] as List,
      );
      expect(cartItems, hasLength(2));
      expect(cartItems[0]['fruitCode'], tProductId1);
      expect(cartItems[0]['quantity'], 2);
      expect(cartItems[1]['fruitCode'], tProductId2);
      expect(cartItems[1]['quantity'], 4);
    });

    test('should return NetworkSuccess and increment quantity when item already exists in cart', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            BackendEndpoints.cartItemsField: [
              {'fruitCode': tProductId1, 'quantity': 2},
            ],
          });

      // Act
      final result = await sut.addItemToCart(tProductId1, quantity: 3);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());

      final userDoc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .get();
      final cartItems = List<Map<String, dynamic>>.from(
        userDoc.data()![BackendEndpoints.cartItemsField] as List,
      );
      expect(cartItems, hasLength(1));
      expect(cartItems.first['fruitCode'], tProductId1);
      expect(cartItems.first['quantity'], 5);
    });

    test('should return NetworkFailure when an exception occurs during adding item to cart', () async {
      // Arrange
      when(() => mockUser.uid).thenThrow(Exception('Firestore error'));

      // Act
      final result = await sut.addItemToCart(tProductId1);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.unexpectedError);
    });
  });

  group('removeItemFromCart', () {
    test('should return NetworkFailure with userNotFound error when currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await sut.removeItemFromCart(tProductId1);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.userNotFound);
    });

    test('should return NetworkSuccess and remove specified item from cart while preserving other items and user fields', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            'email': 'user@example.com',
            BackendEndpoints.cartItemsField: [
              {'fruitCode': tProductId1, 'quantity': 2},
              {'fruitCode': tProductId2, 'quantity': 5},
            ],
          });

      // Act
      final result = await sut.removeItemFromCart(tProductId1);

      // Assert
      expect(result, isA<NetworkSuccess<void>>());

      final userDoc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .get();
      final userData = userDoc.data()!;
      expect(userData['email'], 'user@example.com');

      final cartItems = List<Map<String, dynamic>>.from(
        userData[BackendEndpoints.cartItemsField] as List,
      );
      expect(cartItems, hasLength(1));
      expect(cartItems.first['fruitCode'], tProductId2);
      expect(cartItems.first['quantity'], 5);
    });

    test('should return NetworkSuccess and leave cart unchanged when product does not exist in cart', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            BackendEndpoints.cartItemsField: [
              {'fruitCode': tProductId1, 'quantity': 3},
            ],
          });

      // Act
      final result = await sut.removeItemFromCart('NON_EXISTENT_PRODUCT');

      // Assert
      expect(result, isA<NetworkSuccess<void>>());

      final userDoc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .get();
      final cartItems = List<Map<String, dynamic>>.from(
        userDoc.data()![BackendEndpoints.cartItemsField] as List,
      );
      expect(cartItems, hasLength(1));
      expect(cartItems.first['fruitCode'], tProductId1);
      expect(cartItems.first['quantity'], 3);
    });

    test('should return NetworkFailure when an exception occurs during removing item from cart', () async {
      // Arrange
      when(() => mockUser.uid).thenThrow(Exception('Firestore error'));

      // Act
      final result = await sut.removeItemFromCart(tProductId1);

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.unexpectedError);
    });
  });

  group('getProductsInCart', () {
    test('should return NetworkFailure with userNotFound error when currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await sut.getProductsInCart();

      // Assert
      expect(result, isA<NetworkFailure<List<CartItemEntity>>>());
      final failure = (result as NetworkFailure<List<CartItemEntity>>).failure;
      expect(failure.error, AppStrings.userNotFound);
    });

    test('should return NetworkSuccess with empty list when user document has no cartItems field', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({'name': 'أحمد'});

      // Act
      final result = await sut.getProductsInCart();

      // Assert
      expect(result, isA<NetworkSuccess<List<CartItemEntity>>>());
      final data = (result as NetworkSuccess<List<CartItemEntity>>).data;
      expect(data, isEmpty);
    });

    test('should return NetworkSuccess with empty list when cartItems list is empty', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({BackendEndpoints.cartItemsField: <dynamic>[]});

      // Act
      final result = await sut.getProductsInCart();

      // Assert
      expect(result, isA<NetworkSuccess<List<CartItemEntity>>>());
      final data = (result as NetworkSuccess<List<CartItemEntity>>).data;
      expect(data, isEmpty);
    });

    test('should return NetworkSuccess with list of CartItemEntity with correct quantity and fruit data when products exist in products collection', () async {
      // Arrange: Populate products in productsCollection
      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc(tProductId1)
          .set(tFruitJson1);

      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc(tProductId2)
          .set(tFruitJson2);

      // Populate cart in user document
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            BackendEndpoints.cartItemsField: [
              {'fruitCode': tProductId1, 'quantity': 3},
              {'fruitCode': tProductId2, 'quantity': 5},
            ],
          });

      // Act
      final result = await sut.getProductsInCart();

      // Assert
      expect(result, isA<NetworkSuccess<List<CartItemEntity>>>());
      final items = (result as NetworkSuccess<List<CartItemEntity>>).data!;
      expect(items, hasLength(2));

      final appleItem = items.firstWhere(
        (e) => e.fruitEntity.code == tProductId1,
      );
      expect(appleItem.quantity, 3);
      expect(appleItem.fruitEntity.name, 'تفاح أحمر');
      expect(appleItem.fruitEntity.price, 25.0);
      expect(appleItem.totalPrice, 75.0);

      final bananaItem = items.firstWhere(
        (e) => e.fruitEntity.code == tProductId2,
      );
      expect(bananaItem.quantity, 5);
      expect(bananaItem.fruitEntity.name, 'موز بلدي');
      expect(bananaItem.fruitEntity.price, 15.0);
      expect(bananaItem.totalPrice, 75.0);
    });

    test('should fallback to quantity 1 when fruitCode in product does not match cartItem (orElse branch)', () async {
      // Arrange: product document has different code field than documentId
      final mismatchedProductJson = Map<String, dynamic>.from(tFruitJson1)
        ..['code'] = 'MISMATCHED_CODE';

      await fakeFirestore
          .collection(BackendEndpoints.productsCollection)
          .doc(tProductId1)
          .set(mismatchedProductJson);

      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            BackendEndpoints.cartItemsField: [
              {'fruitCode': tProductId1, 'quantity': 4},
            ],
          });

      // Act
      final result = await sut.getProductsInCart();

      // Assert
      expect(result, isA<NetworkSuccess<List<CartItemEntity>>>());
      final items = (result as NetworkSuccess<List<CartItemEntity>>).data!;
      expect(items, hasLength(1));
      // Fallback orElse triggered: quantity is 1
      expect(items.first.quantity, 1);
      expect(items.first.fruitEntity.code, 'MISMATCHED_CODE');
    });

    test('should return NetworkFailure when an exception occurs during getting products in cart', () async {
      // Arrange
      when(() => mockUser.uid).thenThrow(Exception('Firestore read error'));

      // Act
      final result = await sut.getProductsInCart();

      // Assert
      expect(result, isA<NetworkFailure<List<CartItemEntity>>>());
      final failure = (result as NetworkFailure<List<CartItemEntity>>).failure;
      expect(failure.error, AppStrings.unexpectedError);
    });
  });

  group('updateItemQuantity', () {
    test('should return NetworkFailure with userNotFound error when currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await sut.updateItemQuantity(
        productId: tProductId1,
        newQuantity: 5,
      );

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.userNotFound);
    });

    test('should return NetworkSuccess and update quantity of existing item while preserving existing user fields', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            'phone': '01012345678',
            BackendEndpoints.cartItemsField: [
              {'fruitCode': tProductId1, 'quantity': 2},
              {'fruitCode': tProductId2, 'quantity': 1},
            ],
          });

      // Act
      final result = await sut.updateItemQuantity(
        productId: tProductId1,
        newQuantity: 7,
      );

      // Assert
      expect(result, isA<NetworkSuccess<void>>());

      final userDoc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .get();
      final userData = userDoc.data()!;
      expect(userData['phone'], '01012345678');

      final cartItems = List<Map<String, dynamic>>.from(
        userData[BackendEndpoints.cartItemsField] as List,
      );
      expect(cartItems[0]['fruitCode'], tProductId1);
      expect(cartItems[0]['quantity'], 7);
      expect(cartItems[1]['fruitCode'], tProductId2);
      expect(cartItems[1]['quantity'], 1);
    });

    test('should return NetworkSuccess and leave cart unchanged when product does not exist in cart', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            BackendEndpoints.cartItemsField: [
              {'fruitCode': tProductId1, 'quantity': 2},
            ],
          });

      // Act
      final result = await sut.updateItemQuantity(
        productId: 'NON_EXISTENT_PRODUCT',
        newQuantity: 10,
      );

      // Assert
      expect(result, isA<NetworkSuccess<void>>());

      final userDoc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .get();
      final cartItems = List<Map<String, dynamic>>.from(
        userDoc.data()![BackendEndpoints.cartItemsField] as List,
      );
      expect(cartItems, hasLength(1));
      expect(cartItems.first['fruitCode'], tProductId1);
      expect(cartItems.first['quantity'], 2);
    });

    test('should return NetworkFailure when an exception occurs during updating item quantity', () async {
      // Arrange
      when(() => mockUser.uid).thenThrow(Exception('Firestore update error'));

      // Act
      final result = await sut.updateItemQuantity(
        productId: tProductId1,
        newQuantity: 5,
      );

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.unexpectedError);
    });
  });

  group('clearCart', () {
    test('should return NetworkFailure with userNotFound error when currentUser is null', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await sut.clearCart();

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.userNotFound);
    });

    test('should return NetworkSuccess and reset cartItems to empty list while preserving other user fields', () async {
      // Arrange
      await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .set({
            'email': 'mohamed@example.com',
            'name': 'محمد',
            BackendEndpoints.cartItemsField: [
              {'fruitCode': tProductId1, 'quantity': 3},
              {'fruitCode': tProductId2, 'quantity': 1},
            ],
          });

      // Act
      final result = await sut.clearCart();

      // Assert
      expect(result, isA<NetworkSuccess<void>>());

      final userDoc = await fakeFirestore
          .collection(BackendEndpoints.usersCollection)
          .doc(tUserId)
          .get();
      final userData = userDoc.data()!;
      expect(userData['email'], 'mohamed@example.com');
      expect(userData['name'], 'محمد');

      final cartItems = List<dynamic>.from(
        userData[BackendEndpoints.cartItemsField] as List,
      );
      expect(cartItems, isEmpty);
    });

    test('should return NetworkFailure when an exception occurs during clearing cart', () async {
      // Arrange
      when(() => mockUser.uid).thenThrow(Exception('Firestore write error'));

      // Act
      final result = await sut.clearCart();

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, AppStrings.unexpectedError);
    });
  });

  group('Model and Entity Mappings', () {
    const tFruit = FruitEntity(
      name: 'تفاح',
      description: 'طازج',
      price: 20.0,
      imagePath: 'apple.png',
      code: 'APPLE_01',
    );

    test('CartItemEntity should calculate totalPrice correctly', () {
      // Arrange & Act
      const item = CartItemEntity(fruitEntity: tFruit, quantity: 3);

      // Assert
      expect(item.totalPrice, 60.0);
    });

    test(
      'CartItemEntity copyWith should return modified copy with new values',
      () {
        // Arrange
        const item = CartItemEntity(fruitEntity: tFruit, quantity: 2);

        // Act
        final updated = item.copyWith(quantity: 5);

        // Assert
        expect(updated.quantity, 5);
        expect(updated.fruitEntity, tFruit);
        expect(updated.totalPrice, 100.0);
      },
    );

    test(
      'CartItemEntity toOrderItemEntity should map all properties correctly',
      () {
        // Arrange
        const item = CartItemEntity(fruitEntity: tFruit, quantity: 4);

        // Act
        final orderItem = item.toOrderItemEntity();

        // Assert
        expect(orderItem.name, tFruit.name);
        expect(orderItem.code, tFruit.code);
        expect(orderItem.imagePath, tFruit.imagePath);
        expect(orderItem.price, tFruit.price);
        expect(orderItem.quantity, 4);
      },
    );

    test('CartItemEntity props should support value equality', () {
      // Arrange
      const item1 = CartItemEntity(fruitEntity: tFruit, quantity: 2);
      const item2 = CartItemEntity(fruitEntity: tFruit, quantity: 2);
      const item3 = CartItemEntity(fruitEntity: tFruit, quantity: 3);

      // Assert
      expect(item1, equals(item2));
      expect(item1, isNot(equals(item3)));
    });
  });
}
