import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
import 'package:fruit_hub/features/search/data/data_sources/remote/search_remote_data_source.dart';
import '../../../../../core/helpers/backend_endpoints.dart';
import '../../../../../core/helpers/failures.dart';
import '../../../../../core/helpers/network_response.dart';
import '../../../../../core/services/database/query_parameters.dart';
import '../../../../../shared_data/models/fruit_model.dart';

class SearchRemoteDataSourceImp implements SearchRemoteDataSource {
  SearchRemoteDataSourceImp(this._databaseService);

  final DatabaseService _databaseService;

  @override
  Future<NetworkResponse<List<FruitEntity>>> searchFruits(String query) async {
    try {
      final response = await _databaseService.queryData(
        path: BackendEndpoints.searchProducts,
        query: QueryParameters(searchQuery: query),
      );

      final List<FruitEntity> fruits = response
          .map((e) => FruitModel.fromJson(e).toEntity())
          .toList();

      return NetworkSuccess(fruits);
    } on FirebaseException catch (e) {
      errorLogger(
        functionName: "SearchRemoteDataSourceImp.searchFruits",
        error: e.toString(),
      );
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      errorLogger(
        functionName: "SearchRemoteDataSourceImp.searchFruits",
        error: e.toString(),
      );
      return NetworkFailure(Exception(e.toString()));
    }
  }
}
