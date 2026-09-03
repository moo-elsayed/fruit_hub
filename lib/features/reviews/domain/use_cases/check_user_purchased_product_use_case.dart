import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/reviews/domain/repo/reviews_repo.dart';

class CheckUserPurchasedProductUseCase {
  const CheckUserPurchasedProductUseCase(this._reviewsRepo);

  final ReviewsRepo _reviewsRepo;

  Future<NetworkResponse<bool>> call({required String productCode}) =>
      _reviewsRepo.checkUserPurchasedProduct(productCode: productCode);
}
