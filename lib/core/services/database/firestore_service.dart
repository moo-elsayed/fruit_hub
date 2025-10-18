import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

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
}
