import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/products/domain/entities/paginated_products_entity.dart';
import 'package:fruit_hub/features/products/domain/entities/products_filter_entity.dart';
import 'package:fruit_hub/features/products/domain/repo/products_repo.dart';

class GetAllProductsUseCase {
  GetAllProductsUseCase(this._productsRepo);

  final ProductsRepo _productsRepo;

  Future<NetworkResponse<PaginatedProductsEntity>> call({
    dynamic lastDoc,
    int limit = 10,
    ProductsFilterEntity? filter,
  }) async => await _productsRepo.getProducts(
    lastDoc: lastDoc,
    limit: limit,
    filter: filter,
  );
}
