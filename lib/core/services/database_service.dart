abstract class DatabaseService {
  Future<void> addDataToFirestore({
    required String path,
    required Map<String, dynamic> data,
  });
}
