import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';
import '../../domain/repo/products_repo.dart';
import '../data_sources/remote/products_remote_data_source.dart';

class ProductsRepoImp implements ProductsRepo {
  ProductsRepoImp(this._productsRemoteDataSource);

  final ProductsRemoteDataSource _productsRemoteDataSource;

  @override
  Future<NetworkResponse<List<FruitEntity>>> getAllProducts() async {
    final response = await _productsRemoteDataSource.getAllProducts();
    switch (response) {
      case NetworkSuccess<List<FruitModel>>():
        final entities = (response.data ?? [])
            .map((model) => model.toEntity())
            .toList();
        return NetworkSuccess(entities);
      case NetworkFailure<List<FruitModel>>():
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
