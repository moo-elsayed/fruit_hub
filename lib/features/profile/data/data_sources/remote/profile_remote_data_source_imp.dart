import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
import 'package:fruit_hub/features/profile/data/data_sources/remote/profile_remote_data_source.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';
import '../../../../../core/helpers/failures.dart';
import '../../../../../core/helpers/functions.dart';
import '../../../../../core/helpers/network_response.dart';
import '../../../../../core/services/database/query_parameters.dart';

class ProfileRemoteDataSourceImp implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImp(this._databaseService, this._auth);

  final DatabaseService _databaseService;
  final FirebaseAuth _auth;

  @override
  Future<NetworkResponse<void>> addItemToFavorites(String productId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return NetworkFailure(Exception("user_not_logged_in"));
      }

      final Map<String, dynamic> dataToAdd = {
        'favoriteIds': FieldValue.arrayUnion([productId]),
      };

      await _databaseService.updateData(
        path: BackendEndpoints.updateUserData,
        documentId: userId,
        data: dataToAdd,
      );
      return const NetworkSuccess();
    } on FirebaseException catch (e) {
      _logError(
        e: e,
        functionName: "ProfileRemoteDataSourceImp.addItemToFavorites",
      );
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      _logError(
        e: e,
        functionName: "ProfileRemoteDataSourceImp.addItemToFavorites",
      );
      return NetworkFailure(Exception(e.toString()));
    }
  }

  @override
  Future<NetworkResponse<void>> removeItemFromFavorites(
    String productId,
  ) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return NetworkFailure(Exception("user_not_logged_in"));
      }

      final Map<String, dynamic> dataToRemove = {
        'favoriteIds': FieldValue.arrayRemove([productId]),
      };

      await _databaseService.updateData(
        path: BackendEndpoints.updateUserData,
        documentId: userId,
        data: dataToRemove,
      );
      return const NetworkSuccess();
    } on FirebaseException catch (e) {
      _logError(
        e: e,
        functionName: "ProfileRemoteDataSourceImp.removeItemFromFavorites",
      );
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      _logError(
        e: e,
        functionName: "ProfileRemoteDataSourceImp.removeItemFromFavorites",
      );
      return NetworkFailure(Exception(e.toString()));
    }
  }

  @override
  Future<NetworkResponse<List<String>>> getFavoriteIds() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return NetworkFailure(Exception("user_not_logged_in"));
      }
      final userData = await _databaseService.getData(
        path: BackendEndpoints.getUserData,
        documentId: userId,
      );
      if (userData.containsKey(BackendEndpoints.favoritesIds)) {
        return NetworkSuccess(
          List<String>.from(userData[BackendEndpoints.favoritesIds]),
        );
      } else {
        return const NetworkSuccess([]);
      }
    } on FirebaseException catch (e) {
      _logError(
        e: e,
        functionName: "ProfileRemoteDataSourceImp.getFavoriteIds",
      );
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      _logError(
        e: e,
        functionName: "ProfileRemoteDataSourceImp.getFavoriteIds",
      );
      return NetworkFailure(Exception(e.toString()));
    }
  }

  @override
  Future<NetworkResponse<List<FruitEntity>>> getFavorites(
    List<String> ids,
  ) async {
    try {
      if (ids.isEmpty) {
        return const NetworkSuccess([]);
      }
      final dataList = await _databaseService.queryData(
        path: BackendEndpoints.queryProducts,
        query: QueryParameters(whereInIds: ids),
      );
      return NetworkSuccess(
        dataList.map((e) => FruitModel.fromJson(e).toEntity()).toList(),
      );
    } on FirebaseException catch (e) {
      _logError(e: e, functionName: "ProfileRemoteDataSourceImp.getFavorites");
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      _logError(e: e, functionName: "ProfileRemoteDataSourceImp.getFavorites");
      return NetworkFailure(Exception(e.toString()));
    }
  }

  // -----------------------------------------------------------------

  void _logError({required Object e, required String functionName}) =>
      errorLogger(functionName: functionName, error: e.toString());
}
