import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import '../../domain/repo/home_repo.dart';
import '../data_sources/remote/home_remote_data_source.dart';

class HomeRepoImp implements HomeRepo {
  HomeRepoImp(this._homeRemoteDataSource);

  final HomeRemoteDataSource _homeRemoteDataSource;


  @override
  Future<NetworkResponse<List<FruitEntity>>> getBestSellerProducts() async =>
      await _homeRemoteDataSource.getBestSellerProducts();
}
