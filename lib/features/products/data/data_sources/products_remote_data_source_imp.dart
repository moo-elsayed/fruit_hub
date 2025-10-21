import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
import '../../../../../../core/helpers/failures.dart';
import '../../../../../shared_data/models/fruit_model.dart';
import 'products_remote_data_source.dart';

class ProductsRemoteDataSourceImp implements ProductsRemoteDataSource {
  ProductsRemoteDataSourceImp(this._databaseService);

  final DatabaseService _databaseService;

  @override
  Future<NetworkResponse<List<FruitEntity>>> getAllProducts() async {
    try {
      final response = await _databaseService.getAllData(
        BackendEndpoints.getAllProducts,
      );

      final List<FruitEntity> fruits = response
          .map((e) => FruitModel.fromJson(e).toEntity())
          .toList();

      return NetworkSuccess(fruits);
    } on FirebaseException catch (e) {
      _logError(e: e);
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } catch (e) {
      _logError(e: e);
      return NetworkFailure(Exception(e.toString()));
    }
  }

  void _logError({
    required Object e,
    String functionName = "HomeRemoteDataSourceImp.getAllProducts",
  }) => errorLogger(functionName: functionName, error: e.toString());
}
