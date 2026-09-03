part of 'reviews_cubit.dart';

sealed class ReviewsState {}

final class ReviewsInitial extends ReviewsState {}

final class ReviewsLoaded extends ReviewsState {
  ReviewsLoaded({
    required this.reviews,
    required this.avgRating,
    required this.ratingCount,
    required this.isVerifiedBuyer,
    required this.hasAlreadyReviewed,
    required this.isCheckingEligibility,
  });

  final List<ReviewEntity> reviews;
  final num avgRating;
  final int ratingCount;
  final bool isVerifiedBuyer;
  final bool hasAlreadyReviewed;
  final bool isCheckingEligibility;
}

final class AddReviewLoading extends ReviewsState {}

final class AddReviewSuccess extends ReviewsState {
  AddReviewSuccess(this.newReview);
  final ReviewEntity newReview;
}

final class AddReviewFailure extends ReviewsState {
  AddReviewFailure(this.errorMessage);
  final String errorMessage;
}
