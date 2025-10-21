import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/search/domain/repo/search_repo.dart';

class SearchFruitsUseCase {
  SearchFruitsUseCase(this._searchRepo);

  final SearchRepo _searchRepo;

  Future<NetworkResponse<List<FruitEntity>>> call(String query) async =>
      await _searchRepo.searchFruits(query);
}
