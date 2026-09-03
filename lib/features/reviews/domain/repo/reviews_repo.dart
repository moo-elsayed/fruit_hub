import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';

abstract class ReviewsRepo {
  Future<NetworkResponse<bool>> checkUserPurchasedProduct({
    required String productCode,
  });

  Future<NetworkResponse<void>> addReview({
    required String productCode,
    required ReviewEntity reviewEntity,
  });
}
