import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruit_hub/core/services/database/query_parameters.dart';
import '../../../core/services/database/database_service.dart';

class FirestoreService implements DatabaseService {
  FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<void> addData({
    String? docId,
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final collection = _firestore.collection(path);
    final docRef = docId == null ? collection.doc() : collection.doc(docId);
    await docRef.set(data, SetOptions(merge: true));
  }

  @override
  Future<Map<String, dynamic>> getData({
    required String path,
    required String documentId,
  }) async {
    final snapshot = await _firestore.collection(path).doc(documentId).get();
    return snapshot.data() ?? {};
  }

  @override
  Future<bool> checkIfDataExists({
    required String path,
    required String documentId,
  }) async {
    final snapshot = await _firestore.collection(path).doc(documentId).get();
    return snapshot.exists;
  }

  @override
  Future<void> updateData({
    required String path,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final collection = _firestore.collection(path);
    final docRef = collection.doc(documentId);
    await docRef.update(data);
  }

  @override
  Future<bool> checkIfFieldExists({
    required String path,
    required String fieldName,
    required fieldValue,
  }) async {
    final collection = _firestore.collection(path);
    final querySnapshot = await collection
        .where(fieldName, isEqualTo: fieldValue)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllData(String path) async {
    final snapshot = await _firestore.collection(path).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> queryData({
    required String path,
    required QueryParameters query,
  }) async {
    Query<Map<String, dynamic>> collection = _firestore.collection(path);

    if (query.orderBy != null) {
      collection = collection.orderBy(
        query.orderBy!,
        descending: query.descending,
      );
    }

    if (query.limit != null) {
      collection = collection.limit(query.limit!);
    }

    if (query.searchQuery != null) {
      collection = collection
          .where("name", isGreaterThanOrEqualTo: query.searchQuery)
          .where("name", isLessThanOrEqualTo: '${query.searchQuery}\uf8ff');
    }

    final querySnapshot = await collection.get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
