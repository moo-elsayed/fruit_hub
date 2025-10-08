import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

class FirestoreService implements DatabaseService {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addData({
    String docId = '',
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final collection = _firestore.collection(path);
    final docRef = docId.isEmpty ? collection.doc() : collection.doc(docId);
    await docRef.set(data, SetOptions(merge: true));
  }
}
