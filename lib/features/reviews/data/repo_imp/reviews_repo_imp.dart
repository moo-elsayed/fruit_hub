import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/models/review_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/reviews/data/data_sources/remote/reviews_remote_data_source.dart';
import 'package:fruit_hub/features/reviews/domain/repo/reviews_repo.dart';

class ReviewsRepoImp implements ReviewsRepo {
  const ReviewsRepoImp(this._remoteDataSource);

  final ReviewsRemoteDataSource _remoteDataSource;

  @override
  Future<NetworkResponse<bool>> checkUserPurchasedProduct({
    required String productCode,
  }) => _remoteDataSource.checkUserPurchasedProduct(productCode: productCode);

  @override
  Future<NetworkResponse<void>> addReview({
    required String productCode,
    required ReviewEntity reviewEntity,
  }) => _remoteDataSource.addReview(
    productCode: productCode,
    reviewModel: ReviewModel.fromEntity(reviewEntity),
  );
}
