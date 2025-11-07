import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/products/data/data_sources/products_remote_data_source.dart';
import 'package:fruit_hub/features/products/domain/repo/products_repo.dart';

class ProductsRepoImp implements ProductsRepo {
  ProductsRepoImp(this._productsRemoteDataSource);

  final ProductsRemoteDataSource _productsRemoteDataSource;

  @override
  Future<NetworkResponse<List<FruitEntity>>> getAllProducts() async =>
      await _productsRemoteDataSource.getAllProducts();
}
