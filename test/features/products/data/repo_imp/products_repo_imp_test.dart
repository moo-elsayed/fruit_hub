import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/products/data/data_sources/remote/products_remote_data_source.dart';
import 'package:fruit_hub/features/products/data/repo_imp/products_repo_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockProductsRemoteDataSource extends Mock
    implements ProductsRemoteDataSource {}

void main() {
  late ProductsRepoImp sut;
  late MockProductsRemoteDataSource mockProductsRemoteDataSource;

  List<FruitEntity> fruits = [const FruitEntity(), const FruitEntity(), const FruitEntity()];

  final tSuccessResponse = NetworkSuccess<List<FruitEntity>>(fruits);
  final tFailureResponse = NetworkFailure<List<FruitEntity>>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockProductsRemoteDataSource = MockProductsRemoteDataSource();
    sut = ProductsRepoImp(mockProductsRemoteDataSource);
  });

  group('products repo imp', () {
    test(
      'should call getAllProducts on remote data source and return NetworkSuccess',
      () async {
        // Arrange
        when(
          () => mockProductsRemoteDataSource.getAllProducts(),
        ).thenAnswer((_) async => tSuccessResponse);
        // Act
        final result = await sut.getAllProducts();
        // Assert
        expect(result, tSuccessResponse);
        verify(() => mockProductsRemoteDataSource.getAllProducts());
        verifyNoMoreInteractions(mockProductsRemoteDataSource);
      },
    );

    test(
      'should call getAllProducts on remote data source and return NetworkFailure',
      () async {
        // Arrange
        when(
          () => mockProductsRemoteDataSource.getAllProducts(),
        ).thenAnswer((_) async => tFailureResponse);

        // Act
        final result = await sut.getAllProducts();

        // Assert
        expect(result, tFailureResponse);
        expect(getErrorMessage(result), "permission-denied");
        verify(() => mockProductsRemoteDataSource.getAllProducts());
        verifyNoMoreInteractions(mockProductsRemoteDataSource);
      },
    );
  });
}
