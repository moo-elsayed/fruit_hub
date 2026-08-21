import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';
import '../../domain/repo/search_repo.dart';
import '../data_sources/remote/search_remote_data_source.dart';

class SearchRepoImp implements SearchRepo {
  SearchRepoImp(this._searchRemoteDataSource);

  final SearchRemoteDataSource _searchRemoteDataSource;

  @override
  Future<NetworkResponse<List<FruitEntity>>> searchFruits(String query) async {
    final response = await _searchRemoteDataSource.searchFruits(query);
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
