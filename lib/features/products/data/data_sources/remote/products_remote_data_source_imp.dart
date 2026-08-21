import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/network/api_helper.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';
import 'products_remote_data_source.dart';

class ProductsRemoteDataSourceImp implements ProductsRemoteDataSource {
  ProductsRemoteDataSourceImp({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<NetworkResponse<List<FruitModel>>> getAllProducts() async =>
      ApiHelper.executeSafely(() async {
        final querySnapshot = await _firestore
            .collection(BackendEndpoints.productsCollection)
            .get();

        return querySnapshot.docs
            .map((doc) => FruitModel.fromJson(doc.data()))
            .toList();
      }, functionName: 'getAllProducts');

  @override
  Future<NetworkResponse<FruitModel>> getProductDetails(String code) async =>
      ApiHelper.executeSafely(() async {
        final doc = await _firestore
            .collection(BackendEndpoints.productsCollection)
            .doc(code)
            .get();

        if (!doc.exists || doc.data() == null) {
          throw BusinessException(AppStrings.notFoundError);
        }

        return FruitModel.fromJson(doc.data()!);
      }, functionName: 'getProductDetails');
}
