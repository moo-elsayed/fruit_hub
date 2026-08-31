import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/network/api_helper.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/search/data/data_sources/remote/search_remote_data_source.dart';

class SearchRemoteDataSourceImp implements SearchRemoteDataSource {
  SearchRemoteDataSourceImp({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _productsCollection = BackendEndpoints.productsCollection;

  @override
  Future<NetworkResponse<List<FruitModel>>> searchFruits(String query) async =>
      ApiHelper.executeSafely(() async {
        final querySnapshot = await _firestore
            .collection(_productsCollection)
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: '$query\uf8ff')
            .get();

        return querySnapshot.docs
            .map((doc) => FruitModel.fromJson(doc.data()))
            .toList();
      }, functionName: 'searchFruits');
}
