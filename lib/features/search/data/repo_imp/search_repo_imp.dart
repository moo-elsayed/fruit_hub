import 'package:fruit_hub/core/entities/fruit_entity.dart';
import '../../../../core/helpers/network_response.dart';
import '../../domain/repo/search_repo.dart';
import '../data_sources/search_remote_data_source.dart';

class SearchRepoImp implements SearchRepo {
  SearchRepoImp(this._searchRemoteDataSource);

  final SearchRemoteDataSource _searchRemoteDataSource;

  @override
  Future<NetworkResponse<List<FruitEntity>>> searchFruits(String query) =>
      _searchRemoteDataSource.searchFruits(query);
}
