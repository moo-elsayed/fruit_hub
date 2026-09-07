import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/models/review_model.dart';
import 'package:fruit_hub/core/network/api_helper.dart';
import 'package:fruit_hub/core/network/network_response.dart';

import 'reviews_remote_data_source.dart';

class ReviewsRemoteDataSourceImp implements ReviewsRemoteDataSource {
  ReviewsRemoteDataSourceImp({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<NetworkResponse<bool>> checkUserPurchasedProduct({
    required String productCode,
  }) async => ApiHelper.executeSafely(() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return false;
    }

    final querySnapshot = await _firestore
        .collection(BackendEndpoints.ordersCollection)
        .where('uId', isEqualTo: userId)
        .get();

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final status = data['status'] as String? ?? '';
      if (status.toLowerCase() != OrderStatus.delivered.databaseValue) continue;

      final orderItems = (data['orderItems'] as List<dynamic>? ?? []);
      final hasItem = orderItems.any(
        (item) => item is Map && item['code'] == productCode,
      );
      if (hasItem) return true;
    }

    return false;
  }, functionName: 'checkUserPurchasedProduct');

  @override
  Future<NetworkResponse<void>> addReview({
    required String productCode,
    required ReviewModel reviewModel,
  }) async => ApiHelper.executeSafely(() async {
    final docRef = _firestore
        .collection(BackendEndpoints.productsCollection)
        .doc(productCode);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists || snapshot.data() == null) {
        throw BusinessException(AppStrings.notFoundError);
      }

      final fruitModel = FruitModel.fromJson(snapshot.data()!);
      final updatedReviews = List<ReviewModel>.from(fruitModel.reviews)
        ..add(reviewModel);

      final totalRating = updatedReviews.fold<double>(
        0.0,
        (summation, r) => summation + r.rating,
      );
      final newAvgRating = double.parse(
        (totalRating / updatedReviews.length).toStringAsFixed(1),
      );

      transaction.update(docRef, {
        'reviews': updatedReviews.map((r) => r.toJson()).toList(),
        'avgRating': newAvgRating,
        'ratingCount': updatedReviews.length,
      });
    });
  }, functionName: 'addReview');
}
