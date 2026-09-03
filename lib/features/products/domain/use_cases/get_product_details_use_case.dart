import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/products/domain/repo/products_repo.dart';

import '../../../../core/entities/fruit_entity.dart';

class GetProductDetailsUseCase {
  GetProductDetailsUseCase(this._productsRepo);

  final ProductsRepo _productsRepo;

  Future<NetworkResponse<FruitEntity>> call(String code) async =>
      await _productsRepo.getProductDetails(code);
}
