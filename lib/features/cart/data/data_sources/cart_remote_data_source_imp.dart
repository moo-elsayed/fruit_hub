import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
import 'package:fruit_hub/features/cart/data/data_sources/cart_remote_data_source.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import '../../../../core/helpers/failures.dart';
import '../../../../core/helpers/functions.dart';
import '../models/cart_item_model.dart';

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

      await _databaseService.addData(
        path: cartPath,
        docId: cartModel.fruitCode,
        data: cartModel.toFirestore(),
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

  void _logError({required Object e, required String functionName}) =>
      errorLogger(functionName: functionName, error: e.toString());
}
