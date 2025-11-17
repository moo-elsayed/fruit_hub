import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
import 'package:fruit_hub/features/cart/data/data_sources/remote/cart_remote_data_source.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import '../../../../../core/helpers/failures.dart';
import '../../../../../core/helpers/functions.dart';
import '../../models/cart_item_model.dart';

class CartRemoteDataSourceImp implements CartRemoteDataSource {
  CartRemoteDataSourceImp(this._databaseService, this._auth);

  final DatabaseService _databaseService;
  final FirebaseAuth _auth;

  @override
  Future<NetworkResponse<void>> addItemToCart(CartItemEntity item) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return NetworkFailure(Exception("user_not_logged_in"));
      }

      final String cartPath = 'users/$userId/cart';
      final cartModel = CartItemModel.fromEntity(item);
      final dataMap = cartModel.toJson();

      dataMap.remove('quantity');
      dataMap['quantity'] = FieldValue.increment(1);
      await _databaseService.addData(
        path: cartPath,
        docId: cartModel.fruitCode,
        data: dataMap,
      );
      return const NetworkSuccess();
    } on FirebaseException catch (e) {
      _logError(e: e, functionName: "CartRemoteDataSourceImp.addItemToCart");
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      _logError(e: e, functionName: "CartRemoteDataSourceImp.addItemToCart");
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

      final String cartPath = 'users/$userId/cart';

      await _databaseService.deleteData(path: cartPath, documentId: productId);

      return const NetworkSuccess();
    } on FirebaseException catch (e) {
      _logError(
        e: e,
        functionName: "CartRemoteDataSourceImp.removeItemFromCart",
      );
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      _logError(
        e: e,
        functionName: "CartRemoteDataSourceImp.removeItemFromCart",
      );
      return NetworkFailure(Exception(e.toString()));
    }
  }

  @override
  Future<NetworkResponse<List<CartItemEntity>>> getCartItems() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return NetworkFailure(Exception("user_not_logged_in"));
      }

      final String cartPath = 'users/$userId/cart';

      final response = await _databaseService.getAllData(cartPath);

      final List<CartItemEntity> cartItems = response
          .map((e) => CartItemModel.fromJson(e).toEntity())
          .toList();

      return NetworkSuccess(cartItems);
    } on FirebaseException catch (e) {
      _logError(e: e, functionName: "CartRemoteDataSourceImp.getCartItems");
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      _logError(e: e, functionName: "CartRemoteDataSourceImp.getCartItems");
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

      final String cartPath = 'users/$userId/cart';

      await _databaseService.updateData(
        path: cartPath,
        documentId: productId,
        data: {'quantity': newQuantity},
      );

      return const NetworkSuccess();
    } on FirebaseException catch (e) {
      _logError(
        e: e,
        functionName: "CartRemoteDataSourceImp.updateItemQuantity",
      );
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      _logError(
        e: e,
        functionName: "CartRemoteDataSourceImp.updateItemQuantity",
      );
      return NetworkFailure(Exception(e.toString()));
    }
  }

  // -----------------------------------------------------------------

  void _logError({required Object e, required String functionName}) =>
      errorLogger(functionName: functionName, error: e.toString());
}
