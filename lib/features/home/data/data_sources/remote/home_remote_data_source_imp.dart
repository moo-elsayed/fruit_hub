import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/network/api_helper.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/shared_data/models/fruit_model.dart';
import 'home_remote_data_source.dart';

class HomeRemoteDataSourceImp implements HomeRemoteDataSource {
  HomeRemoteDataSourceImp({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<NetworkResponse<List<FruitModel>>> getBestSellerProducts() async =>
      ApiHelper.executeSafely(() async {
        final querySnapshot = await _firestore
            .collection(BackendEndpoints.productsCollection)
            .orderBy('sellingCount', descending: true)
            .limit(6)
            .get();

        return querySnapshot.docs
            .map((doc) => FruitModel.fromJson(doc.data()))
            .toList();
      }, functionName: 'getBestSellerProducts');
}
