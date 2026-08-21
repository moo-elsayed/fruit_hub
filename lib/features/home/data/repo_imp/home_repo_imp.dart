import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';
import '../../domain/repo/home_repo.dart';
import '../data_sources/remote/home_remote_data_source.dart';

class HomeRepoImp implements HomeRepo {
  HomeRepoImp(this._homeRemoteDataSource);

  final HomeRemoteDataSource _homeRemoteDataSource;

  @override
  Future<NetworkResponse<List<FruitEntity>>> getBestSellerProducts() async {
    final response = await _homeRemoteDataSource.getBestSellerProducts();
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
}
