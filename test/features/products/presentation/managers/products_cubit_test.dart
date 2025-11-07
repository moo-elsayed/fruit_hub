import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/products/domain/use_cases/get_all_products_use_case.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllProductsUseCase extends Mock implements GetAllProductsUseCase {}

void main() {
  late ProductsCubit sut;
  late MockGetAllProductsUseCase mockGetAllProductsUseCase;

  List<FruitEntity> fruits = [FruitEntity(), FruitEntity(), FruitEntity()];

  final tSuccessResponse = NetworkSuccess<List<FruitEntity>>(fruits);
  final tFailureResponse = NetworkFailure<List<FruitEntity>>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockGetAllProductsUseCase = MockGetAllProductsUseCase();
    sut = ProductsCubit(mockGetAllProductsUseCase);
  });

  group('products cubit', () {
    blocTest<ProductsCubit, ProductsState>(
      'emits [GetAllProductsLoading, GetAllProductsSuccess] when getBestSellerProducts is successful',
      build: () => sut,
      setUp: () {
        when(
          () => mockGetAllProductsUseCase.call(),
        ).thenAnswer((_) async => tSuccessResponse);
      },
      act: (bloc) => sut.getAllProducts(),
      expect: () => [
        isA<GetAllProductsLoading>(),
        isA<GetAllProductsSuccess>().having(
          (s) => s.fruits,
          'fruits',
          equals(fruits),
        ),
      ],
      verify: (_) {
        verify(() => mockGetAllProductsUseCase.call()).called(1);
        verifyNoMoreInteractions(mockGetAllProductsUseCase);
      },
    );

    blocTest<ProductsCubit, ProductsState>(
      'emits [GetAllProductsLoading, GetAllProductsFailure] when getBestSellerProducts is unsuccessful',
      build: () => sut,
      setUp: () {
        when(
          () => mockGetAllProductsUseCase.call(),
        ).thenAnswer((_) async => tFailureResponse);
      },
      act: (_) => sut.getAllProducts(),
      expect: () => [
        isA<GetAllProductsLoading>(),
        isA<GetAllProductsFailure>().having(
          (s) => s.error,
          'exception',
          equals(getErrorMessage(tFailureResponse)),
        ),
      ],
      verify: (_) {
        verify(() => mockGetAllProductsUseCase.call()).called(1);
        verifyNoMoreInteractions(mockGetAllProductsUseCase);
      },
    );
  });
}
