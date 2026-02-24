import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
import 'package:fruit_hub/features/cart/data/data_sources/remote/cart_remote_data_source.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';
import '../../../../../core/helpers/app_logger.dart';
import '../../../../../core/helpers/failures.dart';
import '../../../../../core/services/database/query_parameters.dart';

class CartRemoteDataSourceImp implements CartRemoteDataSource {
  CartRemoteDataSourceImp(this._databaseService, this._auth);

  final DatabaseService _databaseService;
  final FirebaseAuth _auth;

  @override
  Future<NetworkResponse<void>> addItemToCart(String productId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return NetworkFailure(Exception("user_not_logged_in"));
      }
      final userData = await _databaseService.getData(
        path: BackendEndpoints.getUserData,
        documentId: userId,
      );
      var cartItems = _getCartItemsHelper(userData);
      int index = cartItems.indexWhere(
        (element) => element['fruitCode'] == productId,
      );
      if (index != -1) {
        int count = cartItems[index]['quantity'];
        cartItems[index]['quantity'] = count + 1;
      } else {
        cartItems.add({'fruitCode': productId, 'quantity': 1});
      }
      await _databaseService.updateData(
        path: BackendEndpoints.updateUserData,
        documentId: userId,
        data: {'cartItems': cartItems},
      );
      return const NetworkSuccess();
    } on FirebaseException catch (e) {
      AppLogger.error("Firebase Error in addItemToCart", error: e);
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      AppLogger.error("Error in addItemToCart", error: e);
      return NetworkFailure(Exception(e.toString()));
    }
  }

  @override
  Future<NetworkResponse<void>> removeItemFromCart(String productId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return NetworkFailure(Exception("user_not_logged_in"));
      }
      final userData = await _databaseService.getData(
        path: BackendEndpoints.getUserData,
        documentId: userId,
      );
      var cartItems = _getCartItemsHelper(userData);
      cartItems.removeWhere((element) => element['fruitCode'] == productId);
      await _databaseService.updateData(
        path: BackendEndpoints.updateUserData,
        documentId: userId,
        data: {'cartItems': cartItems},
      );
      return const NetworkSuccess();
    } on FirebaseException catch (e) {
      AppLogger.error("Firebase Error in removeItemFromCart", error: e);
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      AppLogger.error("Error in removeItemFromCart", error: e);
      return NetworkFailure(Exception(e.toString()));
    }
  }

  @override
  Future<NetworkResponse<List<CartItemEntity>>> getProductsInCart(
    List<Map<String, dynamic>> cartItems,
  ) async {
    try {
      if (cartItems.isEmpty) {
        return const NetworkSuccess([]);
      }
      final dataList = await _databaseService.queryData(
        path: BackendEndpoints.queryProducts,
        query: QueryParameters(
          whereInIds: cartItems.map((e) => e['fruitCode'] as String).toList(),
        ),
      );
      List<FruitEntity> products = dataList
          .map((e) => FruitModel.fromJson(e).toEntity())
          .toList();

      List<CartItemEntity> cartItemsList = [];

      for (var product in products) {
        final cartItemMap = cartItems.firstWhere(
          (element) => element['fruitCode'] == product.code,
        );

        cartItemsList.add(
          CartItemEntity(
            quantity: cartItemMap['quantity'] as int,
            fruitEntity: product,
          ),
        );
      }

      return NetworkSuccess(cartItemsList);
    } on FirebaseException catch (e) {
      AppLogger.error("Firebase Error in getProductsInCart", error: e);
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      AppLogger.error("Error in getProductsInCart", error: e);
      return NetworkFailure(Exception(e.toString()));
    }
  }

  @override
  Future<NetworkResponse<void>> updateItemQuantity({
    required String productId,
    required int newQuantity,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return NetworkFailure(Exception("user_not_logged_in"));
      }

      final userData = await _databaseService.getData(
        documentId: userId,
        path: BackendEndpoints.getUserData,
      );

      var cartItems = _getCartItemsHelper(userData);

      int index = cartItems.indexWhere(
        (element) => element['fruitCode'] == productId,
      );

      if (index != -1) {
        cartItems[index]['quantity'] = newQuantity;
      }

      await _databaseService.updateData(
        path: BackendEndpoints.updateUserData,
        documentId: userId,
        data: {'cartItems': cartItems},
      );

      return const NetworkSuccess();
    } on FirebaseException catch (e) {
      AppLogger.error("Firebase Error in updateItemQuantity", error: e);
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      AppLogger.error("Error in updateItemQuantity", error: e);
      return NetworkFailure(Exception(e.toString()));
    }
  }

  @override
  Future<NetworkResponse<List<Map<String, dynamic>>>> getCartItems() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return NetworkFailure(Exception("user_not_logged_in"));
      }
      final userData = await _databaseService.getData(
        path: BackendEndpoints.getUserData,
        documentId: userId,
      );
      return NetworkSuccess(_getCartItemsHelper(userData));
    } on FirebaseException catch (e) {
      AppLogger.error("Firebase Error in getCartItems", error: e);
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      AppLogger.error("Error in getCartItems", error: e);
      return NetworkFailure(Exception(e.toString()));
    }
  }

  @override
  Future<NetworkResponse<void>> clearCart() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return NetworkFailure(Exception("user_not_logged_in"));
      }
      await _databaseService.updateData(
        path: BackendEndpoints.getUserData,
        documentId: userId,
        data: {BackendEndpoints.cartItems: []},
      );
      return const NetworkSuccess();
    } on FirebaseException catch (e) {
      AppLogger.error("Firebase Error in clearCart", error: e);
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      AppLogger.error("Error in clearCart", error: e);
      return NetworkFailure(Exception(e.toString()));
    }
  }

  // -----------------------------------------------------------------

  List<Map<String, dynamic>> _getCartItemsHelper(
    Map<String, dynamic> userData,
  ) => userData[BackendEndpoints.cartItems] != null
      ? List<Map<String, dynamic>>.from(
          (userData[BackendEndpoints.cartItems] as List).map(
            (e) => Map<String, dynamic>.from(e),
          ),
        )
      : [];
}
