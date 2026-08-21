import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/cart/domain/repo/cart_repo.dart';

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
