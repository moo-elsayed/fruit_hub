import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';
import '../../../../core/helpers/network_response.dart';

class UpdateItemQuantityUseCase {
  UpdateItemQuantityUseCase(this._cartRepo);

  final CartRepo _cartRepo;

  Future<NetworkResponse<void>> call({
    required String productId,
    required int newQuantity,
  }) async => _cartRepo.updateItemQuantity(
    productId: productId,
    newQuantity: newQuantity,
  );
}
