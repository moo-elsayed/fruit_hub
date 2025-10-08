abstract class DatabaseService {
  Future<void> addData({
    String docId = '',
    required String path,
    required Map<String, dynamic> data,
  });
}
