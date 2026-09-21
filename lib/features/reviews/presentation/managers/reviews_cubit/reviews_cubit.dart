import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/reviews/domain/use_cases/check_user_purchased_product_use_case.dart';

part 'reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  ReviewsCubit({
    required this.checkUserPurchasedProductUseCase,
    required this.fruit,
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance,
       super(
         ReviewsState(
           reviews: List.unmodifiable(fruit.reviews),
           avgRating: fruit.avgRating,
           ratingCount: fruit.ratingCount,
         ),
       ) {
    _init();
  }

  final CheckUserPurchasedProductUseCase checkUserPurchasedProductUseCase;
  final FruitEntity fruit;
  final FirebaseAuth _auth;

  List<ReviewEntity> get reviews => state.reviews;
  num get avgRating => state.avgRating;
  int get ratingCount => state.ratingCount;
  bool get isVerifiedBuyer => state.isVerifiedBuyer;
  bool get hasAlreadyReviewed => state.hasAlreadyReviewed;
  bool get isCheckingEligibility => state.isCheckingEligibility;

  @override
  void emit(ReviewsState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> _init() async {
    final currentUser = _auth.currentUser;
    var hasAlreadyReviewed = false;
    var isVerifiedBuyer = false;

    if (currentUser != null) {
      hasAlreadyReviewed = state.reviews.any(
        (r) => r.userId.isNotEmpty && r.userId == currentUser.uid,
      );

      emit(state.copyWith(hasAlreadyReviewed: hasAlreadyReviewed));

      final result = await checkUserPurchasedProductUseCase(
        productCode: fruit.code,
      );
      if (isClosed) return;
      switch (result) {
        case NetworkSuccess<bool>():
          isVerifiedBuyer = result.data ?? false;
        case NetworkFailure<bool>():
          isVerifiedBuyer = false;
          hasAlreadyReviewed = false;
      }
    }

    if (isClosed) return;
    emit(
      state.copyWith(
        isCheckingEligibility: false,
        isVerifiedBuyer: isVerifiedBuyer,
        hasAlreadyReviewed: hasAlreadyReviewed,
      ),
    );
  }

  void addReviewLocally(ReviewEntity newReview) {
    final updatedReviews = [newReview, ...state.reviews];
    final totalRating = updatedReviews.fold<double>(
      0.0,
      (summation, r) => summation + r.rating,
    );
    final newAvgRating = double.parse(
      (totalRating / updatedReviews.length).toStringAsFixed(1),
    );

    emit(
      state.copyWith(
        reviews: List.unmodifiable(updatedReviews),
        avgRating: newAvgRating,
        ratingCount: updatedReviews.length,
        hasAlreadyReviewed: true,
      ),
    );
  }
}
