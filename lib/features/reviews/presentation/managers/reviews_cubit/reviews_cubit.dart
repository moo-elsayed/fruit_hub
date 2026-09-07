import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/reviews/domain/use_cases/add_review_use_case.dart';
import 'package:fruit_hub/features/reviews/domain/use_cases/check_user_purchased_product_use_case.dart';

part 'reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  ReviewsCubit({
    required this.checkUserPurchasedProductUseCase,
    required this.addReviewUseCase,
    required this.fruit,
  }) : super(ReviewsInitial()) {
    _init();
  }

  final CheckUserPurchasedProductUseCase checkUserPurchasedProductUseCase;
  final AddReviewUseCase addReviewUseCase;
  final FruitEntity fruit;

  late final List<ReviewEntity> _reviews = List.from(fruit.reviews);
  late num _avgRating = fruit.avgRating;
  late int _ratingCount = fruit.ratingCount;
  bool _isVerifiedBuyer = false;
  bool _hasAlreadyReviewed = false;
  bool _isCheckingEligibility = true;

  List<ReviewEntity> get reviews => _reviews;
  num get avgRating => _avgRating;
  int get ratingCount => _ratingCount;
  bool get isVerifiedBuyer => _isVerifiedBuyer;
  bool get hasAlreadyReviewed => _hasAlreadyReviewed;
  bool get isCheckingEligibility => _isCheckingEligibility;

  @override
  void emit(ReviewsState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  void _emitLoaded() {
    if (isClosed) return;
    emit(
      ReviewsLoaded(
        reviews: List.unmodifiable(_reviews),
        avgRating: _avgRating,
        ratingCount: _ratingCount,
        isVerifiedBuyer: _isVerifiedBuyer,
        hasAlreadyReviewed: _hasAlreadyReviewed,
        isCheckingEligibility: _isCheckingEligibility,
      ),
    );
  }

  Future<void> _init() async {
    _emitLoaded();

    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserName =
        currentUser?.displayName?.trim() ?? currentUser?.email ?? '';

    // Check if current user has already reviewed
    if (currentUser != null) {
      _hasAlreadyReviewed = _reviews.any(
        (r) =>
            (r.userId.isNotEmpty && r.userId == currentUser.uid) ||
            (r.name.trim().isNotEmpty &&
                (r.name.trim() == currentUserName ||
                    (currentUser.email != null &&
                        r.name.trim() == currentUser.email))),
      );

      _emitLoaded();

      final result = await checkUserPurchasedProductUseCase(
        productCode: fruit.code,
      );
      if (isClosed) return;
      if (result is NetworkSuccess<bool>) {
        _isVerifiedBuyer = result.data ?? false;
      }
    } else {
      _isVerifiedBuyer = false;
      _hasAlreadyReviewed = false;
    }

    if (isClosed) return;
    _isCheckingEligibility = false;
    _emitLoaded();
  }

  Future<void> submitReview({
    required double rating,
    required String comment,
    required String userName,
    String? userImage,
    String? userId,
  }) async {
    emit(AddReviewLoading());

    final isoDate = DateTime.now().toIso8601String();
    final newReview = ReviewEntity(
      name: userName.isNotEmpty ? userName : 'User',
      image: userImage ?? '',
      description: comment.trim(),
      date: isoDate,
      rating: rating,
      userId: userId ?? '',
    );

    final result = await addReviewUseCase(
      productCode: fruit.code,
      reviewEntity: newReview,
    );

    if (isClosed) return;

    switch (result) {
      case NetworkSuccess<void>():
        _reviews.insert(0, newReview);
        final totalRating = _reviews.fold<double>(0.0, (s, r) => s + r.rating);
        _avgRating = double.parse(
          (totalRating / _reviews.length).toStringAsFixed(1),
        );
        _ratingCount = _reviews.length;
        _hasAlreadyReviewed = true;
        emit(AddReviewSuccess(newReview));
        _emitLoaded();
      case NetworkFailure<void>():
        emit(AddReviewFailure(result.error));
        _emitLoaded();
    }
  }
}
