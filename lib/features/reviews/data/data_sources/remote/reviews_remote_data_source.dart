import 'package:fruit_hub/core/models/review_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';

abstract class ReviewsRemoteDataSource {
  Future<NetworkResponse<bool>> checkUserPurchasedProduct({
    required String productCode,
  });

  Future<NetworkResponse<void>> addReview({
    required String productCode,
    required ReviewModel reviewModel,
  });
}
