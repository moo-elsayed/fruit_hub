import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/services/database/query_parameters.dart';
import 'package:fruit_hub/shared_data/services/database/firestore_service.dart';

void main() {
  late FirestoreService sut;
  late FakeFirebaseFirestore fakeFirestore;

  const tPath = 'users';
  const tDocId = '123';
  const tData = {'name': 'Test User'};
  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    sut = FirestoreService(fakeFirestore);
  });

  group('add data', () {
    test('should add data to firestore when docId is provided', () async {
      // Arrange
      // Act
      await sut.addData(docId: tDocId, path: tPath, data: tData);
      // Assert
      final snapshot = await fakeFirestore.collection(tPath).doc(tDocId).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data(), equals(tData));
    });

    test('should generate docId when docId is null', () async {
      // Arrange
      // Act
      sut.addData(path: tPath, data: tData);
      // Assert
      var snapshot = await fakeFirestore.collection(tPath).get();
      expect(snapshot.docs.length, equals(1));
      expect(snapshot.docs.first.data(), equals(tData));
    });

    test('should merge data when SetOptions(merge: true) is used', () async {
      // Arrange
      const oldData = {'name': 'Old Name', 'age': 30};
      await fakeFirestore.collection(tPath).doc(tDocId).set(oldData);
      const newData = {'name': 'New Name', 'age': 40};
      // Act
      await sut.addData(docId: tDocId, path: tPath, data: newData);
      // Assert
      final snapshot = await fakeFirestore.collection(tPath).doc(tDocId).get();
      expect(snapshot.data(), equals({'name': 'New Name', 'age': 40}));
    });
  });

  group('get data', () {
    test('should return data when document exists', () async {
      // Arrange
      await fakeFirestore.collection(tPath).doc(tDocId).set(tData);
      // Act
      final result = await sut.getData(path: tPath, documentId: tDocId);
      // Assert
      expect(result, equals(tData));
    });

    test('should return empty map when document does not exist', () async {
      // Act
      final result = await sut.getData(path: tPath, documentId: tDocId);
      // Assert
      expect(result, equals({}));
    });
  });

  group('check if data exists', () {
    test('should return true when document exists', () async {
      // Arrange
      await fakeFirestore.collection(tPath).doc(tDocId).set(tData);
      // Act
      final result = await sut.checkIfDataExists(
        path: tPath,
        documentId: tDocId,
      );
      // Assert
      expect(result, isTrue);
    });

    test('should return false when document does not exist', () async {
      // Arrange
      // Act
      final result = await sut.checkIfDataExists(
        path: tPath,
        documentId: tDocId,
      );
      // Assert
      expect(result, isFalse);
    });
  });

  group('update data', () {
    const tOriginalData = {'name': 'Original Name', 'age': 30};
    const tUpdatedData = {'age': 20};
    const result = {'name': 'Original Name', 'age': 20};
    test('should update data successfully when document exists', () async {
      // Arrange
      await fakeFirestore.collection(tPath).doc(tDocId).set(tOriginalData);
      // Act
      await sut.updateData(path: tPath, documentId: tDocId, data: tUpdatedData);
      // Assert
      final snapshot = await fakeFirestore.collection(tPath).doc(tDocId).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data(), equals(result));
    });
    test('should throw exception when document does not exist', () {
      // Arrange
      // Act
      var updateData = sut.updateData(
        path: tPath,
        documentId: tDocId,
        data: tUpdatedData,
      );
      // Assert
      expect(() => updateData, throwsException);
    });
  });

  group('check if field exists', () {
    test('should return true when field with value exists', () async {
      // Arrange
      await fakeFirestore.collection(tPath).doc(tDocId).set(tData);
      // Act
      final result = await sut.checkIfFieldExists(
        path: tPath,
        fieldName: 'name',
        fieldValue: 'Test User',
      );
      // Assert
      expect(result, isTrue);
    });
    test('should return false when field with value does not exist', () async {
      // Arrange
      await fakeFirestore.collection(tPath).doc(tDocId).set(tData);
      // Act
      var result = await sut.checkIfFieldExists(
        path: tPath,
        fieldName: 'name',
        fieldValue: 'New User',
      );
      // Assert
      expect(result, isFalse);
    });
    test('should return false when field does not exist', () async {
      // Arrange
      await fakeFirestore.collection(tPath).doc(tDocId).set(tData);
      // Act
      var result = await sut.checkIfFieldExists(
        path: tPath,
        fieldName: 'age',
        fieldValue: 30,
      );
      // Assert
      expect(result, isFalse);
    });
  });
  group('get all data', () {
    const tData2 = {'name': 'Another User', 'age': 30};
    test('should return a list of data when collection is not empty', () async {
      // Arrange
      await fakeFirestore.collection(tPath).doc(tDocId).set(tData);
      await fakeFirestore.collection(tPath).doc('456').set(tData2);
      // Act
      final result = await sut.getAllData(tPath);
      // Assert
      expect(result, isNotEmpty);
      expect(result.length, 2);
      expect(
        result.where((element) => element.containsValue('Test User')).first,
        tData,
      );
      expect(
        result.where((element) => element.containsValue('Another User')).first,
        tData2,
      );
    });
    test('should return an empty list when collection is empty', () async {
      // Arrange
      // Act
      final result = await sut.getAllData(tPath);
      // Assert
      expect(result, isEmpty);
    });
  });
  group('query data', () {
    final docA = {'name': 'Apple', 'age': 20};
    final docB = {'name': 'Banana', 'age': 30};
    final docC = {'name': 'Apricot', 'age': 10};
    setUp(() async {
      await fakeFirestore.collection(tPath).doc('A').set(docA);
      await fakeFirestore.collection(tPath).doc('B').set(docB);
      await fakeFirestore.collection(tPath).doc('C').set(docC);
    });
    test('should return all data when query is empty', () async {
      // Arrange
      final query = const QueryParameters();
      // Act
      final result = await sut.queryData(path: tPath, query: query);
      // Assert
      expect(result.length, 3);
      expect(
        result.where((element) => element.containsValue('Apricot')).first,
        docC,
      );
      expect(
        result.where((element) => element.containsValue('Banana')).first,
        docB,
      );
      expect(
        result.where((element) => element.containsValue('Apple')).first,
        docA,
      );
    });
    test('should filter data based on orderBy (descending)', () async {
      // Arrange
      final query = const QueryParameters(orderBy: 'name', descending: true);
      // Act
      final result = await sut.queryData(path: tPath, query: query);
      // Assert
      expect(result.length, 3);
      expect(
        result.where((element) => element.containsValue('Apricot')).first,
        docC,
      );
      expect(
        result.where((element) => element.containsValue('Banana')).first,
        docB,
      );
      expect(
        result.where((element) => element.containsValue('Apple')).first,
        docA,
      );
    });
    test('should filter data based on limit', () async {
      // Arrange
      final query = const QueryParameters(limit: 2, orderBy: 'name');
      // Act
      final result = await sut.queryData(path: tPath, query: query);
      // Assert
      expect(result.length, 2);
      expect(
        result.where((element) => element.containsValue('Apricot')).first,
        docC,
      );
      expect(
        result.where((element) => element.containsValue('Apple')).first,
        docA,
      );
    });

    test('should combine all query parameters correctly', () async {
      // Arrange
      final query = const QueryParameters(
        searchQuery: 'Ap',
        orderBy: 'name',
        descending: true,
        limit: 1,
      );
      // Act
      final result = await sut.queryData(path: tPath, query: query);
      // Assert
      expect(result.length, 1);
      expect(result.first, docC);
    });
  });

  group('delete data', () {
    const tPath = 'users/MPftaMy6QegYipyXw8mYGNG7pa42/cart';
    test('should delete data successfully when document exists', () async {
      // Arrange
      await fakeFirestore.collection(tPath).doc(tDocId).set(tData);
      // Act
      await sut.deleteData(path: tPath, documentId: tDocId);
      // Assert
      final snapshot = await fakeFirestore.collection(tPath).doc(tDocId).get();
      expect(snapshot.exists, isFalse);
      expect(snapshot.data(), isNull);
      expect(snapshot.metadata.hasPendingWrites, isFalse);
    });

    test(
      'should complete successfully (not throw) when document does not exist',
      () {
        // Arrange (empty, doc doesn't exist)
        // Act
        final call = sut.deleteData(path: tPath, documentId: tDocId);
        // Assert
        expect(call, completes);
      },
    );
  });
}
