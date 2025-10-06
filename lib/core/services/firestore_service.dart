import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

class FirestoreService implements DatabaseService {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addDataToFirestore({
    required String path,
    required Map<String, dynamic> data,
  }) {
    // TODO: implement addDataToFirestore
    throw UnimplementedError();
  }
}
