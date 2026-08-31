import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/models/fruit_model.dart';
import 'package:fruit_hub/core/network/api_helper.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/products/data/models/paginated_products_data.dart';
import 'package:fruit_hub/features/products/data/models/products_filter_model.dart';

import 'products_remote_data_source.dart';

class ProductsRemoteDataSourceImp implements ProductsRemoteDataSource {
  ProductsRemoteDataSourceImp({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<NetworkResponse<PaginatedProductsData>> getProducts({
    dynamic lastDoc,
    int limit = 10,
    ProductsFilterModel? filter,
  }) async => ApiHelper.executeSafely(() async {
    Query<Map<String, dynamic>> query = _firestore.collection(
      BackendEndpoints.productsCollection,
    );

    // Apply Category Filters
    if (filter != null) {
      final categoryField = filter.categoryFilter.firestoreField;
      if (categoryField != null) {
        query = query.where(categoryField, isEqualTo: true);
      }

      // Apply Sorting
      final sortField = filter.sortType.firestoreField;
      if (sortField != null) {
        query = query.orderBy(
          sortField,
          descending: filter.sortType.isDescending,
        );
      }
    }

    query = query.limit(limit);

    if (lastDoc is DocumentSnapshot) {
      query = query.startAfterDocument(lastDoc);
    }

    final querySnapshot = await query.get();
    final fruits = querySnapshot.docs
        .map((doc) => FruitModel.fromJson(doc.data()))
        .toList();

    final newLastDoc = querySnapshot.docs.isNotEmpty
        ? querySnapshot.docs.last
        : null;
    final hasMore = querySnapshot.docs.length == limit;

    return PaginatedProductsData(
      fruits: fruits,
      lastDoc: newLastDoc,
      hasMore: hasMore,
    );
  }, functionName: 'getProducts');

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
