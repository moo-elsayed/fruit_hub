import 'package:fruit_hub/core/services/database/query_parameters.dart';

abstract class DatabaseService {
  Future<void> addData({
    String? docId,
    required String path,
    required Map<String, dynamic> data,
  });

  Future<Map<String, dynamic>> getData({
    required String path,
    required String documentId,
  });

  Future<List<Map<String, dynamic>>> getAllData(String path);

  Future<List<Map<String, dynamic>>> queryData({
    required String path,
    required QueryParameters query,
  });

  Future<bool> checkIfDataExists({
    required String path,
    required String documentId,
  });

  Future<bool> checkIfFieldExists({
    required String path,
    required String fieldName,
    required dynamic fieldValue,
  });

  Future<void> updateData({
    required String path,
    required String documentId,
    required Map<String, dynamic> data,
  });
}
