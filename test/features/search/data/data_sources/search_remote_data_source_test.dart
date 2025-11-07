import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
import 'package:fruit_hub/core/services/database/query_parameters.dart';
import 'package:fruit_hub/features/search/data/data_sources/search_remote_data_source_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late SearchRemoteDataSourceImp sut;
  late MockDatabaseService mockDatabaseService;

  const tSearchQuery = 'man';
  const tPath = BackendEndpoints.searchProducts;
  const tQueryParameters = QueryParameters(searchQuery: tSearchQuery);

  const tRawData = [
    {
      'name': 'mango',
      'description':
          'Este combo é composto por uma seleção de frutas vermelhas frescas e suculentas, incluindo morangos, framboesas, mirtilos e amoras. Elas são ricas em antioxidantes, vitaminas e fibras, tornando-as uma opção saudável e deliciosa para qualquer hora do dia. São perfeitas para consumir in natura, em saladas de frutas, smoothies, iogurtes ou como ingrediente em diversas receitas.',
      'price': 18.5,
      'imagePath': 'assets/images/combo_frutas_vermelhas.png',
      'code': 'FV001',
      'isFeatured': true,
      'avgRating': 4.8,
      'ratingCount': 250,
      'isOrganic': true,
      'daysUntilExpiration': 5,
      'unitAmount': 500,
      'numberOfCalories': 57,
      'reviews': [],
      'sellingCount': 100,
    },
  ];

  final tFirebaseException = FirebaseException(
    plugin: 'firestore',
    code: 'permission-denied',
    message: 'Permission denied on collection.',
  );

  setUpAll(() {
    registerFallbackValue(tQueryParameters);
  });

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    sut = SearchRemoteDataSourceImp(mockDatabaseService);
  });

  group('SearchRemoteDataSourceImp', () {
    test(
      'should return NetworkSuccess<List<FruitEntity>> when queryData is successful',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.queryData(
            path: tPath,
            query: tQueryParameters,
          ),
        ).thenAnswer((_) async => tRawData);
        // Act
        final result = await sut.searchFruits(tSearchQuery);
        // Assert
        expect(result, isA<NetworkSuccess<List<FruitEntity>>>());
        final data = (result as NetworkSuccess).data;
        expect(data, isA<List<FruitEntity>>());
        expect(data.length, tRawData.length);
        verify(
          () => mockDatabaseService.queryData(
            path: tPath,
            query: tQueryParameters,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test(
      'should return NetworkFailure when queryData throws FirebaseException',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.queryData(
            path: tPath,
            query: tQueryParameters,
          ),
        ).thenThrow(tFirebaseException);
        // Act
        final result = await sut.searchFruits(tSearchQuery);
        // Assert
        expect(result, isA<NetworkFailure>());
        expect(getErrorMessage(result), "permission-denied");
        verify(
          () => mockDatabaseService.queryData(
            path: tPath,
            query: tQueryParameters,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );
  });
}
