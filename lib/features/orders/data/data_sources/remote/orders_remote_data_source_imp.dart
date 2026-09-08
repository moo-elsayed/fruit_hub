import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/models/order_model.dart';

import 'orders_remote_data_source.dart';

class OrdersRemoteDataSourceImp implements OrdersRemoteDataSource {
  OrdersRemoteDataSourceImp({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Stream<List<OrderModel>> streamUserOrders() {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection(BackendEndpoints.ordersCollection)
        .where('uId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => OrderModel.fromSnapshot(doc))
              .toList();
          orders.sort((a, b) => b.date.compareTo(a.date));
          return orders;
        });
  }

  @override
  Stream<OrderModel> streamOrderById(String orderId) {
    final collection = _firestore.collection(BackendEndpoints.ordersCollection);
    final numericId = int.tryParse(orderId);

    if (numericId != null) {
      return collection
          .where('orderId', isEqualTo: numericId)
          .limit(1)
          .snapshots()
          .asyncMap((snapshot) async {
            if (snapshot.docs.isNotEmpty) {
              return OrderModel.fromSnapshot(snapshot.docs.first);
            }
            final doc = await collection.doc(orderId).get();
            if (doc.exists && doc.data() != null) {
              return OrderModel.fromSnapshot(doc);
            }
            throw BusinessException(AppStrings.notFoundError);
          });
    }

    return collection.doc(orderId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return OrderModel.fromSnapshot(doc);
      }
      throw BusinessException(AppStrings.notFoundError);
    });
  }

  @override
  Future<void> cancelOrder(String docId) async {
    final docRef = _firestore
        .collection(BackendEndpoints.ordersCollection)
        .doc(docId);

    final doc = await docRef.get();
    if (!doc.exists) {
      throw BusinessException(AppStrings.notFoundError);
    }

    final currentStatus = doc.data()?['status'] as String? ?? '';
    if (currentStatus.toLowerCase() != OrderStatus.pending.databaseValue) {
      throw BusinessException(AppStrings.cannotCancelOrder);
    }

    await docRef.update({'status': OrderStatus.cancelled.databaseValue});
  }
}
