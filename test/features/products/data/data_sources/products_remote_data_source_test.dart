import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/database/database_service.dart';
import 'package:fruit_hub/features/products/data/data_sources/products_remote_data_source_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late ProductsRemoteDataSourceImp sut;
  late MockDatabaseService mockDatabaseService;

  const tPath = BackendEndpoints.getAllProducts;

  const tRawData = [
    {
      'name': 'Combo Frutas Vermelhas',
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
    {
      'name': 'Combo Frutas Tropicais',
      'description':
          'Este combo exótico traz uma mistura vibrante de frutas tropicais, como manga, abacaxi, mamão e maracujá. Com sabores doces e levemente ácidos, são uma excelente fonte de vitaminas A e C, além de enzimas digestivas. Ideal para um café da manhã refrescante, sobremesas tropicais ou para adicionar um toque especial a sucos e coquetéis.',
      'price': 22.0,
      'imagePath': 'assets/images/combo_frutas_tropicais.png',
      'code': 'FT002',
      'isFeatured': true,
      'avgRating': 4.9,
      'ratingCount': 300,
      'isOrganic': false,
      'daysUntilExpiration': 7,
      'unitAmount': 100,
      'numberOfCalories': 60,
      'reviews': [],
      'sellingCount': 150,
    },
  ];

  final tFirebaseException = FirebaseException(
    plugin: 'firestore',
    code: 'permission-denied',
    message: 'Permission denied on collection.',
  );

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    sut = ProductsRemoteDataSourceImp(mockDatabaseService);
  });

  group('products remote data source', () {
    test(
      'should return NetworkSuccess<List<FruitEntity>> in success',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.getAllData(tPath),
        ).thenAnswer((_) async => tRawData);
        // Act
        final result = await sut.getAllProducts();
        // Assert
        expect(result, isA<NetworkSuccess<List<FruitEntity>>>());
        final data = (result as NetworkSuccess).data;
        expect(data, isA<List<FruitEntity>>());
        expect(data.length, tRawData.length);
        verify(() => mockDatabaseService.getAllData(tPath)).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );

    test(
      'should return NetworkFailure when getAllData throws FirebaseException',
      () async {
        // Arrange
        when(
          () => mockDatabaseService.getAllData(tPath),
        ).thenThrow(tFirebaseException);

        // Act
        final result = await sut.getAllProducts();

        // Assert
        expect(result, isA<NetworkFailure>());
        expect(getErrorMessage(result), "permission-denied");
        verify(() => mockDatabaseService.getAllData(tPath)).called(1);
        verifyNoMoreInteractions(mockDatabaseService);
      },
    );
  });
}
