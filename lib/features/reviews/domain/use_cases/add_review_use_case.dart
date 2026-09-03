import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/reviews/domain/repo/reviews_repo.dart';

class AddReviewUseCase {
  const AddReviewUseCase(this._reviewsRepo);

  final ReviewsRepo _reviewsRepo;

  Future<NetworkResponse<void>> call({
    required String productCode,
    required ReviewEntity reviewEntity,
  }) => _reviewsRepo.addReview(
    productCode: productCode,
    reviewEntity: reviewEntity,
  );
}
