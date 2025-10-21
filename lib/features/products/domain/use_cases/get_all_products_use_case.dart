import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/products/domain/repo/products_repo.dart';

class GetAllProductsUseCase {
  GetAllProductsUseCase(this._productsRepo);

  final ProductsRepo _productsRepo;

  Future<NetworkResponse<List<FruitEntity>>> call() async =>
      await _productsRepo.getAllProducts();
}
