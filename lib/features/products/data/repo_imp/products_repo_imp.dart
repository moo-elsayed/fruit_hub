import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/products/data/models/paginated_products_data.dart';
import 'package:fruit_hub/features/products/data/models/products_filter_model.dart';
import 'package:fruit_hub/features/products/domain/entities/paginated_products_entity.dart';
import 'package:fruit_hub/features/products/domain/entities/products_filter_entity.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';
import '../../domain/repo/products_repo.dart';
import '../data_sources/remote/products_remote_data_source.dart';

class ProductsRepoImp implements ProductsRepo {
  ProductsRepoImp(this._productsRemoteDataSource);

  final ProductsRemoteDataSource _productsRemoteDataSource;

  @override
  Future<NetworkResponse<PaginatedProductsEntity>> getProducts({
    dynamic lastDoc,
    int limit = 10,
    ProductsFilterEntity? filter,
  }) async {
    final response = await _productsRemoteDataSource.getProducts(
      lastDoc: lastDoc,
      limit: limit,
      filter: filter != null ? ProductsFilterModel.fromEntity(filter) : null,
    );
    switch (response) {
      case NetworkSuccess<PaginatedProductsData>():
        final data = response.data!;
        final entities = data.fruits.map((model) => model.toEntity()).toList();
        return NetworkSuccess(
          PaginatedProductsEntity(
            fruits: entities,
            lastDoc: data.lastDoc,
            hasMore: data.hasMore,
          ),
        );
      case NetworkFailure<PaginatedProductsData>():
        return NetworkFailure(response.failure);
    }
  }

  @override
  Future<NetworkResponse<FruitEntity>> getProductDetails(String code) async {
    final response = await _productsRemoteDataSource.getProductDetails(code);
    switch (response) {
      case NetworkSuccess<FruitModel>():
        return NetworkSuccess(response.data!.toEntity());
      case NetworkFailure<FruitModel>():
        return NetworkFailure(response.failure);
    }
  }
}
