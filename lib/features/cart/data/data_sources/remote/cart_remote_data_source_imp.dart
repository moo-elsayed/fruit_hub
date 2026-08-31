import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/network/api_helper.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/cart/data/data_sources/remote/cart_remote_data_source.dart';

class CartRemoteDataSourceImp implements CartRemoteDataSource {
  CartRemoteDataSourceImp({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const String _usersCollection = BackendEndpoints.usersCollection;
  static const String _productsCollection = BackendEndpoints.productsCollection;

  @override
  Future<NetworkResponse<void>> addItemToCart(
    String productId, {
    int quantity = 1,
  }) async => ApiHelper.executeSafely(() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw BusinessException(AppStrings.userNotFound);
    }
    final userDoc = await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .get();
    final userData = userDoc.data() ?? {};
    final cartItems = _getCartItemsHelper(userData);
    final int index = cartItems.indexWhere(
      (element) =>
          element['fruitCode'] == productId ||
          element['productId'] == productId,
    );
    if (index != -1) {
      cartItems[index]['quantity'] =
          ((cartItems[index]['quantity'] as num?)?.toInt() ?? 0) + quantity;
    } else {
      cartItems.add({'fruitCode': productId, 'quantity': quantity});
    }
    await _firestore.collection(_usersCollection).doc(userId).set({
      BackendEndpoints.cartItemsField: cartItems,
    }, SetOptions(merge: true));
  }, functionName: 'addItemToCart');

  @override
  Future<NetworkResponse<void>> removeItemFromCart(String productId) async =>
      ApiHelper.executeSafely(() async {
        final userId = _auth.currentUser?.uid;
        if (userId == null) {
          throw BusinessException(AppStrings.userNotFound);
        }
        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .get();
        final userData = userDoc.data() ?? {};
        final cartItems = _getCartItemsHelper(userData);
        cartItems.removeWhere(
          (element) =>
              element['fruitCode'] == productId ||
              element['productId'] == productId,
        );
        await _firestore.collection(_usersCollection).doc(userId).set({
          BackendEndpoints.cartItemsField: cartItems,
        }, SetOptions(merge: true));
      }, functionName: 'removeItemFromCart');

  @override
  Future<NetworkResponse<List<CartItemEntity>>> getProductsInCart() async =>
      ApiHelper.executeSafely(() async {
        final userId = _auth.currentUser?.uid;
        if (userId == null) {
          throw BusinessException(AppStrings.userNotFound);
        }
        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .get();
        final userData = userDoc.data() ?? {};
        final cartItems = _getCartItemsHelper(userData);
        if (cartItems.isEmpty) {
          return <CartItemEntity>[];
        }

        final productIds = cartItems
            .map((e) => (e['fruitCode'] ?? e['productId']) as String)
            .toList();

        final querySnapshot = await _firestore
            .collection(_productsCollection)
            .where(FieldPath.documentId, whereIn: productIds)
            .get();

        final List<CartItemEntity> result = [];
        for (final doc in querySnapshot.docs) {
          final fruitModel = FruitModel.fromJson(doc.data());
          final cartItemMap = cartItems.firstWhere(
            (element) =>
                element['fruitCode'] == fruitModel.code ||
                element['productId'] == fruitModel.code,
            orElse: () => {'quantity': 1},
          );
          result.add(
            CartItemEntity(
              quantity: (cartItemMap['quantity'] as num?)?.toInt() ?? 1,
              fruitEntity: fruitModel.toEntity(),
            ),
          );
        }
        return result;
      }, functionName: 'getProductsInCart');

  @override
  Future<NetworkResponse<void>> updateItemQuantity({
    required String productId,
    required int newQuantity,
  }) async => ApiHelper.executeSafely(() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw BusinessException(AppStrings.userNotFound);
    }
    final userDoc = await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .get();
    final userData = userDoc.data() ?? {};
    final cartItems = _getCartItemsHelper(userData);
    final int index = cartItems.indexWhere(
      (element) =>
          element['fruitCode'] == productId ||
          element['productId'] == productId,
    );
    if (index != -1) {
      cartItems[index]['quantity'] = newQuantity;
    }
    await _firestore.collection(_usersCollection).doc(userId).set({
      BackendEndpoints.cartItemsField: cartItems,
    }, SetOptions(merge: true));
  }, functionName: 'updateItemQuantity');

  @override
  Future<NetworkResponse<void>> clearCart() async =>
      ApiHelper.executeSafely(() async {
        final userId = _auth.currentUser?.uid;
        if (userId == null) {
          throw BusinessException(AppStrings.userNotFound);
        }
        await _firestore.collection(_usersCollection).doc(userId).set({
          BackendEndpoints.cartItemsField: [],
        }, SetOptions(merge: true));
      }, functionName: 'clearCart');

  // -----------------------------------------------------------------

  List<Map<String, dynamic>> _getCartItemsHelper(
    Map<String, dynamic> userData,
  ) => userData[BackendEndpoints.cartItemsField] != null
      ? List<Map<String, dynamic>>.from(
          (userData[BackendEndpoints.cartItemsField] as List).map(
            (e) => Map<String, dynamic>.from(e),
          ),
        )
      : [];
}
