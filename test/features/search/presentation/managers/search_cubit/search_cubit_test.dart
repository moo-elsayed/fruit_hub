import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/search/domain/use_cases/search_fruits_use_case.dart';
import 'package:fruit_hub/features/search/presentation/managers/search_cubit/search_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchFruitsUseCase extends Mock implements SearchFruitsUseCase {}

void main() {
  late MockSearchFruitsUseCase mockSearchFruitsUseCase;
  late SearchCubit sut;

  const tQuery = 'تفاح';
  const tErrorMessage = 'حدث خطأ أثناء البحث عن المنتجات';
  const tServerFailure = ServerFailure(error: tErrorMessage);

  const tFruitEntities = [
    FruitEntity(
      name: 'تفاح أحمر',
      description: 'تفاح أحمر طازج ولذيذ',
      price: 25.0,
      imagePath: 'assets/images/apple_red.png',
      code: 'APPLE_01',
      isFeatured: true,
      avgRating: 4.5,
      ratingCount: 15,
      isOrganic: true,
      daysUntilExpiration: 10,
      weightInGrams: 500,
      numberOfCalories: 52,
      reviews: [],
    ),
  ];

  setUp(() {
    mockSearchFruitsUseCase = MockSearchFruitsUseCase();
    sut = SearchCubit(mockSearchFruitsUseCase);
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be SearchInitial', () {
    // Assert
    expect(sut.state, isA<SearchInitial>());
  });

  group('resetSearch', () {
    blocTest<SearchCubit, SearchState>(
      'should emit [SearchInitial] when resetSearch is called',
      build: () => sut,
      seed: () => SearchSuccess(tFruitEntities),
      act: (cubit) => cubit.resetSearch(),
      expect: () => [isA<SearchInitial>()],
    );
  });

  group('searchProducts', () {
    blocTest<SearchCubit, SearchState>(
      'should emit [SearchLoading, SearchSuccess] with fruits when use case returns NetworkSuccess with fruits',
      build: () => sut,
      setUp: () {
        // Arrange
        when(
          () => mockSearchFruitsUseCase.call(tQuery),
        ).thenAnswer((_) async => const NetworkSuccess(tFruitEntities));
      },
      act: (cubit) async {
        // Act
        await cubit.searchProducts(tQuery);
      },
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchSuccess>().having(
          (state) => state.fruits,
          'fruits',
          tFruitEntities,
        ),
      ],
      verify: (_) {
        // Assert
        verify(() => mockSearchFruitsUseCase.call(tQuery)).called(1);
        verifyNoMoreInteractions(mockSearchFruitsUseCase);
      },
    );

    blocTest<SearchCubit, SearchState>(
      'should emit [SearchLoading, SearchSuccess] with empty list when use case returns NetworkSuccess with null data',
      build: () => sut,
      setUp: () {
        // Arrange
        when(
          () => mockSearchFruitsUseCase.call(tQuery),
        ).thenAnswer((_) async => const NetworkSuccess(null));
      },
      act: (cubit) async {
        // Act
        await cubit.searchProducts(tQuery);
      },
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchSuccess>().having(
          (state) => state.fruits,
          'fruits',
          isEmpty,
        ),
      ],
      verify: (_) {
        // Assert
        verify(() => mockSearchFruitsUseCase.call(tQuery)).called(1);
        verifyNoMoreInteractions(mockSearchFruitsUseCase);
      },
    );

    blocTest<SearchCubit, SearchState>(
      'should emit [SearchLoading, SearchFailure] with correct error message when use case returns NetworkFailure',
      build: () => sut,
      setUp: () {
        // Arrange
        when(
          () => mockSearchFruitsUseCase.call(tQuery),
        ).thenAnswer((_) async => const NetworkFailure(tServerFailure));
      },
      act: (cubit) async {
        // Act
        await cubit.searchProducts(tQuery);
      },
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchFailure>().having(
          (state) => state.errorMessage,
          'errorMessage',
          tErrorMessage,
        ),
      ],
      verify: (_) {
        // Assert
        verify(() => mockSearchFruitsUseCase.call(tQuery)).called(1);
        verifyNoMoreInteractions(mockSearchFruitsUseCase);
      },
    );
  });
}
