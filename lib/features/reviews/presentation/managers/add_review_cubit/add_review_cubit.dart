import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';

import '../../../domain/use_cases/add_review_use_case.dart';

part 'add_review_state.dart';

class AddReviewCubit extends Cubit<AddReviewState> {
  AddReviewCubit(this._addReviewUseCase) : super(AddReviewInitial());

  final AddReviewUseCase _addReviewUseCase;

  Future<void> submitReview({
    required String productCode,
    required ReviewEntity reviewEntity,
  }) async {
    emit(AddReviewLoading());

    final result = await _addReviewUseCase(
      productCode: productCode,
      reviewEntity: reviewEntity,
    );

    if (isClosed) return;

    switch (result) {
      case NetworkSuccess<void>():
        emit(AddReviewSuccess(reviewEntity));
      case NetworkFailure<void>():
        emit(AddReviewFailure(result.error));
    }
  }
}
