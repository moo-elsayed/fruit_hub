import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/network/api_helper.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/favorites/data/data_sources/remote/favorites_remote_data_source.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';

class FavoritesRemoteDataSourceImp implements FavoritesRemoteDataSource {
  FavoritesRemoteDataSourceImp({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const String _usersCollection = BackendEndpoints.usersCollection;
  static const String _productsCollection = BackendEndpoints.productsCollection;

  @override
  Future<NetworkResponse<void>> addItemToFavorites(String productId) async =>
      ApiHelper.executeSafely(() async {
        final userId = _auth.currentUser?.uid;
        if (userId == null) {
          throw BusinessException(AppStrings.userNotFound);
        }

        await _firestore.collection(_usersCollection).doc(userId).update({
          BackendEndpoints.favoriteIdsField: FieldValue.arrayUnion([productId]),
        });
      }, functionName: 'addItemToFavorites');

  @override
  Future<NetworkResponse<void>> removeItemFromFavorites(
    String productId,
  ) async => ApiHelper.executeSafely(() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw BusinessException(AppStrings.userNotFound);
    }

    await _firestore.collection(_usersCollection).doc(userId).update({
      BackendEndpoints.favoriteIdsField: FieldValue.arrayRemove([productId]),
    });
  }, functionName: 'removeItemFromFavorites');

  @override
  Future<NetworkResponse<List<String>>> getFavoriteIds() async =>
      ApiHelper.executeSafely(() async {
        final userId = _auth.currentUser?.uid;
        if (userId == null) {
          throw BusinessException(AppStrings.userNotFound);
        }

        final docSnapshot = await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .get();
        final userData = docSnapshot.data() ?? {};
        if (userData.containsKey(BackendEndpoints.favoriteIdsField)) {
          return List<String>.from(userData[BackendEndpoints.favoriteIdsField]);
        }
        return <String>[];
      }, functionName: 'getFavoriteIds');

  @override
  Future<NetworkResponse<List<FruitModel>>> getFavorites(
    List<String> ids,
  ) async => ApiHelper.executeSafely(() async {
    if (ids.isEmpty) {
      return <FruitModel>[];
    }

    final querySnapshot = await _firestore
        .collection(_productsCollection)
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return querySnapshot.docs
        .map((doc) => FruitModel.fromJson(doc.data()))
        .toList();
  }, functionName: 'getFavorites');
}
