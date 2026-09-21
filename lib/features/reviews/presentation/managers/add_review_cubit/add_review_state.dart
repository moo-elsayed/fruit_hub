part of 'add_review_cubit.dart';

@immutable
sealed class AddReviewState {}

final class AddReviewInitial extends AddReviewState {}

final class AddReviewLoading extends AddReviewState {}

final class AddReviewSuccess extends AddReviewState {
  AddReviewSuccess(this.newReview);

  final ReviewEntity newReview;
}

final class AddReviewFailure extends AddReviewState {
  AddReviewFailure(this.errorMessage);

  final String errorMessage;
}
