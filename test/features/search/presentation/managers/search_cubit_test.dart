import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/search/domain/use_cases/search_fruits_use_case.dart';
import 'package:fruit_hub/features/search/presentation/managers/search_cubit/search_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchFruitsUseCase extends Mock implements SearchFruitsUseCase {}

void main() {
  late SearchCubit sut;
  late MockSearchFruitsUseCase mockSearchFruitsUseCase;

  List<FruitEntity> fruits = [FruitEntity(), FruitEntity(), FruitEntity()];
  const tSearchQuery = 'man';
  final tSuccessResponse = NetworkSuccess<List<FruitEntity>>(fruits);
  final tFailureResponse = NetworkFailure<List<FruitEntity>>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockSearchFruitsUseCase = MockSearchFruitsUseCase();
    sut = SearchCubit(mockSearchFruitsUseCase);
  });

  group('search cubit', () {
    test('initial state should be SearchInitial', () {
      expect(sut.state, isA<SearchInitial>());
    });

    blocTest<SearchCubit, SearchState>(
      'emits [SearchLoading, SearchSuccess] when searchProducts is successful',
      build: () => sut,
      setUp: () {
        when(
          () => mockSearchFruitsUseCase.call(tSearchQuery),
        ).thenAnswer((_) async => tSuccessResponse);
      },
      act: (cubit) => cubit.searchProducts(tSearchQuery),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchSuccess>().having((s) => s.fruits, 'fruits', equals(fruits)),
      ],
      verify: (_) {
        verify(() => mockSearchFruitsUseCase.call(tSearchQuery)).called(1);
        verifyNoMoreInteractions(mockSearchFruitsUseCase);
      },
    );

    blocTest<SearchCubit, SearchState>(
      'emits [SearchLoading, SearchFailure] when searchProducts is unsuccessful',
      build: () => sut,
      setUp: () {
        when(
          () => mockSearchFruitsUseCase.call(tSearchQuery),
        ).thenAnswer((_) async => tFailureResponse);
      },
      act: (_) => sut.searchProducts(tSearchQuery),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchFailure>().having(
          (s) => s.errorMessage,
          'exception',
          equals(getErrorMessage(tFailureResponse)),
        ),
      ],
      verify: (_) {
        verify(() => mockSearchFruitsUseCase.call(tSearchQuery)).called(1);
        verifyNoMoreInteractions(mockSearchFruitsUseCase);
      },
    );
  });
}
