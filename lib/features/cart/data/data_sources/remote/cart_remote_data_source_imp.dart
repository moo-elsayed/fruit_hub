import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/network/api_helper.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/cart/data/data_sources/remote/cart_remote_data_source.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';

class CartRemoteDataSourceImp implements CartRemoteDataSource {
  CartRemoteDataSourceImp({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const String _usersCollection = BackendEndpoints.usersCollection;
  static const String _productsCollection = BackendEndpoints.productsCollection;

  @override
  Future<NetworkResponse<void>> addItemToCart(String productId) async =>
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
        final int index = cartItems.indexWhere(
          (element) => element['fruitCode'] == productId,
        );
        if (index != -1) {
          cartItems[index]['quantity'] =
              (cartItems[index]['quantity'] as int) + 1;
        } else {
          cartItems.add({'fruitCode': productId, 'quantity': 1});
        }
        await _firestore.collection(_usersCollection).doc(userId).update({
          'cartItems': cartItems,
        });
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
        cartItems.removeWhere((element) => element['fruitCode'] == productId);
        await _firestore.collection(_usersCollection).doc(userId).update({
          'cartItems': cartItems,
        });
      }, functionName: 'removeItemFromCart');

  @override
  Future<NetworkResponse<List<Map<String, dynamic>>>> getCartItems() async =>
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
        return _getCartItemsHelper(userData);
      }, functionName: 'getCartItems');

  @override
  Future<NetworkResponse<List<FruitModel>>> getCartProducts(
    List<String> productIds,
  ) async => ApiHelper.executeSafely(() async {
    if (productIds.isEmpty) {
      return <FruitModel>[];
    }
    final querySnapshot = await _firestore
        .collection(_productsCollection)
        .where(FieldPath.documentId, whereIn: productIds)
        .get();

    return querySnapshot.docs
        .map((e) => FruitModel.fromJson(e.data()))
        .toList();
  }, functionName: 'getCartProducts');

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
      (element) => element['fruitCode'] == productId,
    );
    if (index != -1) {
      cartItems[index]['quantity'] = newQuantity;
    }
    await _firestore.collection(_usersCollection).doc(userId).update({
      'cartItems': cartItems,
    });
  }, functionName: 'updateItemQuantity');

  @override
  Future<NetworkResponse<void>> clearCart() async =>
      ApiHelper.executeSafely(() async {
        final userId = _auth.currentUser?.uid;
        if (userId == null) {
          throw BusinessException(AppStrings.userNotFound);
        }
        await _firestore.collection(_usersCollection).doc(userId).update({
          BackendEndpoints.cartItemsField: [],
        });
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
