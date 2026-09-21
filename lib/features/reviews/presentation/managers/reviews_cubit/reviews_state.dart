part of 'reviews_cubit.dart';

class ReviewsState extends Equatable {
  const ReviewsState({
    this.reviews = const [],
    this.avgRating = 0.0,
    this.ratingCount = 0,
    this.isVerifiedBuyer = false,
    this.hasAlreadyReviewed = false,
    this.isCheckingEligibility = true,
  });

  final List<ReviewEntity> reviews;
  final num avgRating;
  final int ratingCount;
  final bool isVerifiedBuyer;
  final bool hasAlreadyReviewed;
  final bool isCheckingEligibility;

  ReviewsState copyWith({
    List<ReviewEntity>? reviews,
    num? avgRating,
    int? ratingCount,
    bool? isVerifiedBuyer,
    bool? hasAlreadyReviewed,
    bool? isCheckingEligibility,
  }) => ReviewsState(
    reviews: reviews ?? this.reviews,
    avgRating: avgRating ?? this.avgRating,
    ratingCount: ratingCount ?? this.ratingCount,
    isVerifiedBuyer: isVerifiedBuyer ?? this.isVerifiedBuyer,
    hasAlreadyReviewed: hasAlreadyReviewed ?? this.hasAlreadyReviewed,
    isCheckingEligibility: isCheckingEligibility ?? this.isCheckingEligibility,
  );

  @override
  List<Object?> get props => [
    reviews,
    avgRating,
    ratingCount,
    isVerifiedBuyer,
    hasAlreadyReviewed,
    isCheckingEligibility,
  ];
}
