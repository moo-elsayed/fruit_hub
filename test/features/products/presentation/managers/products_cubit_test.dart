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

  final fruit1 = const FruitEntity(
    name: 'Apple',
    price: 20,
    code: '1',
    description: '',
    imagePath: '',
  );
  final fruit2 = const FruitEntity(
    name: 'Orange',
    price: 30,
    code: '3',
    description: '',
    imagePath: '',
  );
  final fruit3 = const FruitEntity(
    name: 'Banana',
    price: 10,
    code: '2',
    description: '',
    imagePath: '',
  );

  List<FruitEntity> fruits = [fruit1, fruit2, fruit3];

  final tSuccessResponse = NetworkSuccess<List<FruitEntity>>(fruits);
  final tFailureResponse = NetworkFailure<List<FruitEntity>>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockGetAllProductsUseCase = MockGetAllProductsUseCase();
    sut = ProductsCubit(mockGetAllProductsUseCase);
  });

  group('products cubit', () {
    test('initial state should be ProductsInitial', () {
      expect(sut.state, isA<ProductsInitial>());
    });

    group('getAllProducts', () {
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

    group('sortProducts', () {
      blocTest<ProductsCubit, ProductsState>(
        "sorts products from lowest to highest price correctly",
        build: () => sut,
        setUp: () {
          when(
            () => mockGetAllProductsUseCase.call(),
          ).thenAnswer((_) async => tSuccessResponse);
        },
        act: (cubit) async {
          await cubit.getAllProducts();
          cubit.sortProducts(0);
        },
        expect: () => [
          isA<GetAllProductsLoading>(),
          isA<GetAllProductsSuccess>().having(
            (s) => s.fruits,
            'fruits',
            equals(fruits),
          ),
          isA<GetAllProductsSuccess>().having(
            (s) => s.fruits,
            'fruits',
            equals([fruit3, fruit1, fruit2]),
          ),
        ],
        verify: (_) {
          verify(() => mockGetAllProductsUseCase.call()).called(1);
          verifyNoMoreInteractions(mockGetAllProductsUseCase);
        },
      );

      blocTest<ProductsCubit, ProductsState>(
        "sorts products from highest to lowest price correctly",
        build: () => sut,
        setUp: () {
          when(
            () => mockGetAllProductsUseCase.call(),
          ).thenAnswer((_) async => tSuccessResponse);
        },
        act: (cubit) async {
          await cubit.getAllProducts();
          cubit.sortProducts(1);
        },
        expect: () => [
          isA<GetAllProductsLoading>(),
          isA<GetAllProductsSuccess>().having(
            (s) => s.fruits,
            'fruits',
            equals(fruits),
          ),
          isA<GetAllProductsSuccess>().having(
            (s) => s.fruits,
            'fruits',
            equals([fruit2, fruit1, fruit3]),
          ),
        ],
        verify: (_) {
          verify(() => mockGetAllProductsUseCase.call()).called(1);
          verifyNoMoreInteractions(mockGetAllProductsUseCase);
        },
      );

      blocTest<ProductsCubit, ProductsState>(
        "sorts products alphabetically",
        build: () => sut,
        setUp: () {
          when(
            () => mockGetAllProductsUseCase.call(),
          ).thenAnswer((_) async => tSuccessResponse);
        },
        act: (cubit) async {
          await cubit.getAllProducts();
          cubit.sortProducts(2);
        },
        expect: () => [
          isA<GetAllProductsLoading>(),
          isA<GetAllProductsSuccess>().having(
            (s) => s.fruits,
            'fruits',
            equals(fruits),
          ),
          isA<GetAllProductsSuccess>().having(
            (s) => s.fruits,
            'fruits',
            equals([fruit1, fruit3, fruit2]),
          ),
        ],
        verify: (_) {
          verify(() => mockGetAllProductsUseCase.call()).called(1);
          verifyNoMoreInteractions(mockGetAllProductsUseCase);
        },
      );
    });
  });
}
