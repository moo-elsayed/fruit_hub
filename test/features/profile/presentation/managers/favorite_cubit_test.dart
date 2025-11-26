import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/add_item_to_favorites_use_case.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/get_favorite_ids_use_case.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/get_favorites_use_case.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/remove_item_from_favorites_use_case.dart';
import 'package:fruit_hub/features/profile/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAddItemToFavoritesUseCase extends Mock
    implements AddItemToFavoritesUseCase {}

class MockRemoveItemFromFavoritesUseCase extends Mock
    implements RemoveItemFromFavoritesUseCase {}

class MockGetFavoriteIdsUseCase extends Mock implements GetFavoriteIdsUseCase {}

class MockGetFavoritesUseCase extends Mock implements GetFavoritesUseCase {}

void main() {
  late FavoriteCubit sut;
  late MockAddItemToFavoritesUseCase mockAddItemToFavoritesUseCase;
  late MockRemoveItemFromFavoritesUseCase mockRemoveItemFromFavoritesUseCase;
  late MockGetFavoriteIdsUseCase mockGetFavoriteIdsUseCase;
  late MockGetFavoritesUseCase mockGetFavoritesUseCase;

  const tProductId = 'apple_red';
  const tFavoritesList = ['id1', 'id2'];
  final tSuccessResponseOfTypeListOfString = const NetworkSuccess<List<String>>(
    tFavoritesList,
  );
  final tFailureResponseOfTypeListOfString = NetworkFailure<List<String>>(
    Exception("permission-denied"),
  );
  List<FruitEntity> fruits = [const FruitEntity(), const FruitEntity(), const FruitEntity()];

  final tSuccessResponseOfTypeListFruitEntity =
      NetworkSuccess<List<FruitEntity>>(fruits);
  final tFailureResponseOfTypeListFruitEntity =
      NetworkFailure<List<FruitEntity>>(Exception("permission-denied"));
  final tSuccessResponseOfTypeVoid = const NetworkSuccess<void>();
  final tFailureResponseOfTypeVoid = NetworkFailure<void>(
    Exception("permission-denied"),
  );

  setUp(() {
    mockAddItemToFavoritesUseCase = MockAddItemToFavoritesUseCase();
    mockRemoveItemFromFavoritesUseCase = MockRemoveItemFromFavoritesUseCase();
    mockGetFavoriteIdsUseCase = MockGetFavoriteIdsUseCase();
    mockGetFavoritesUseCase = MockGetFavoritesUseCase();
    sut = FavoriteCubit(
      mockAddItemToFavoritesUseCase,
      mockRemoveItemFromFavoritesUseCase,
      mockGetFavoriteIdsUseCase,
      mockGetFavoritesUseCase,
    );
  });

  group("favorite cubit", () {
    test('initial state should be FavoriteInitial', () {
      expect(sut.state, isA<FavoriteInitial>());
    });

    group('ToggleFavorite', () {
      blocTest<FavoriteCubit, FavoriteState>(
        'should call addItemToFavoritesUseCase, add id to list, and emit ToggleFavoriteSuccess when item is NOT in favorites',
        build: () => sut,
        setUp: () {
          when(
            () => mockAddItemToFavoritesUseCase.call(tProductId),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
        },
        act: (cubit) => cubit.toggleFavorite(tProductId),
        expect: () => [isA<ToggleFavoriteSuccess>()],
        verify: (cubit) {
          verify(
            () => mockAddItemToFavoritesUseCase.call(tProductId),
          ).called(1);
          verifyNever(() => mockRemoveItemFromFavoritesUseCase.call(any()));
          expect(cubit.isFavorite(tProductId), true);
        },
      );

      blocTest<FavoriteCubit, FavoriteState>(
        'should call removeItemFromFavoritesUseCase, remove id from list, and emit ToggleFavoriteSuccess when item IS in favorites',
        build: () => sut,
        setUp: () {
          when(
            () => mockGetFavoriteIdsUseCase.call(),
          ).thenAnswer((_) async => const NetworkSuccess([tProductId]));
          when(
            () => mockRemoveItemFromFavoritesUseCase.call(tProductId),
          ).thenAnswer((_) async => tSuccessResponseOfTypeVoid);
        },
        act: (cubit) async {
          await cubit.getFavoriteIds();
          await cubit.toggleFavorite(tProductId);
        },
        skip: 1,
        expect: () => [isA<ToggleFavoriteSuccess>()],
        verify: (cubit) {
          verify(
            () => mockRemoveItemFromFavoritesUseCase.call(tProductId),
          ).called(1);
          verifyNever(() => mockAddItemToFavoritesUseCase.call(any()));
          expect(cubit.isFavorite(tProductId), false);
        },
      );

      blocTest<FavoriteCubit, FavoriteState>(
        'should emit ToggleFavoriteFailure when addItemToFavoritesUseCase fails',
        build: () => sut,
        setUp: () {
          when(
            () => mockAddItemToFavoritesUseCase.call(tProductId),
          ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
        },
        act: (cubit) => cubit.toggleFavorite(tProductId),
        expect: () => [
          isA<ToggleFavoriteFailure>().having(
            (state) => state.errorMessage,
            'errorMessage',
            equals(getErrorMessage(tFailureResponseOfTypeVoid)),
          ),
        ],
        verify: (cubit) {
          verify(
            () => mockAddItemToFavoritesUseCase.call(tProductId),
          ).called(1);
          verifyNever(() => mockRemoveItemFromFavoritesUseCase.call(any()));
          expect(cubit.isFavorite(tProductId), false);
        },
      );

      blocTest<FavoriteCubit, FavoriteState>(
        'should emit ToggleFavoriteFailure when removeItemFromFavoritesUseCase fails',
        build: () => sut,
        setUp: () {
          when(
            () => mockGetFavoriteIdsUseCase.call(),
          ).thenAnswer((_) async => const NetworkSuccess([tProductId]));
          when(
            () => mockRemoveItemFromFavoritesUseCase.call(tProductId),
          ).thenAnswer((_) async => tFailureResponseOfTypeVoid);
        },
        act: (cubit) async {
          await cubit.getFavoriteIds();
          await cubit.toggleFavorite(tProductId);
        },
        skip: 1,
        expect: () => [
          isA<ToggleFavoriteFailure>().having(
            (state) => state.errorMessage,
            'errorMessage',
            equals(getErrorMessage(tFailureResponseOfTypeVoid)),
          ),
        ],
        verify: (cubit) {
          verify(
            () => mockRemoveItemFromFavoritesUseCase.call(tProductId),
          ).called(1);
          verifyNever(() => mockAddItemToFavoritesUseCase.call(any()));
          expect(cubit.isFavorite(tProductId), true);
        },
      );
    });

    group('GetFavorites', () {
      blocTest<FavoriteCubit, FavoriteState>(
        'should emit [GetFavoritesLoading, GetFavoritesSuccess] when data is gotten successfully',
        build: () => sut,
        setUp: () {
          when(
            () => mockGetFavoritesUseCase.call(any()),
          ).thenAnswer((_) async => tSuccessResponseOfTypeListFruitEntity);
        },
        act: (cubit) => cubit.getFavorites(),
        expect: () => [isA<GetFavoritesLoading>(), isA<GetFavoritesSuccess>()],
        verify: (cubit) {
          verify(() => mockGetFavoritesUseCase.call(any())).called(1);
          expect(cubit.state, isA<GetFavoritesSuccess>());
          expect((cubit.state as GetFavoritesSuccess).favorites, fruits);
        },
      );

      blocTest<FavoriteCubit, FavoriteState>(
        'should emit [GetFavoritesLoading, GetFavoritesFailure] when getting data fails',
        build: () => sut,
        setUp: () {
          when(
            () => mockGetFavoritesUseCase.call(any()),
          ).thenAnswer((_) async => tFailureResponseOfTypeListFruitEntity);
        },
        act: (cubit) => cubit.getFavorites(),
        expect: () => [
          isA<GetFavoritesLoading>(),
          isA<GetFavoritesFailure>().having(
            (state) => state.errorMessage,
            'errorMessage',
            equals(getErrorMessage(tFailureResponseOfTypeListFruitEntity)),
          ),
        ],
        verify: (cubit) {
          verify(() => mockGetFavoritesUseCase.call(any())).called(1);
          expect(cubit.state, isA<GetFavoritesFailure>());
        },
      );
    });

    group('GetFavoriteIds', () {
      blocTest<FavoriteCubit, FavoriteState>(
        'should emit GetFavoriteIdsSuccess and update internal list when API returns success',
        build: () => sut,
        setUp: () {
          when(
            () => mockGetFavoriteIdsUseCase.call(),
          ).thenAnswer((_) async => tSuccessResponseOfTypeListOfString);
        },
        act: (cubit) => cubit.getFavoriteIds(),
        expect: () => [isA<GetFavoriteIdsSuccess>()],
        verify: (cubit) {
          verify(() => mockGetFavoriteIdsUseCase.call()).called(1);
          expect(cubit.isFavorite('id1'), true);
          expect(cubit.isFavorite('id2'), true);
          expect(cubit.isFavorite('unknown_id'), false);
        },
      );

      blocTest<FavoriteCubit, FavoriteState>(
        'should emit GetFavoriteIdsFailure when API returns failure',
        build: () => sut,
        setUp: () {
          when(
            () => mockGetFavoriteIdsUseCase.call(),
          ).thenAnswer((_) async => tFailureResponseOfTypeListOfString);
        },
        act: (cubit) => cubit.getFavoriteIds(),
        expect: () => [
          isA<GetFavoriteIdsFailure>().having(
            (state) => state.errorMessage,
            'errorMessage',
            equals(getErrorMessage(tFailureResponseOfTypeListOfString)),
          ),
        ],
        verify: (cubit) {
          verify(() => mockGetFavoriteIdsUseCase.call()).called(1);
          expect(cubit.state, isA<GetFavoriteIdsFailure>());
          expect(cubit.isFavorite('id1'), false);
          expect(cubit.isFavorite('id2'), false);
          expect(cubit.isFavorite('unknown_id'), false);
        },
      );
    });

    group('isFavorite', () {
      test('should return false initially (empty list)', () {
        expect(sut.isFavorite('any_id'), false);
      });

      test(
        'should return true only if item exists in the list after loading',
        () async {
          // Arrange
          when(
            () => mockGetFavoriteIdsUseCase.call(),
          ).thenAnswer((_) async => tSuccessResponseOfTypeListOfString);
          // Act
          await sut.getFavoriteIds();
          // Assert
          expect(sut.isFavorite('id1'), true);
          expect(sut.isFavorite('id2'), true);
          expect(sut.isFavorite('unknown_id'), false);
        },
      );
    });
  });
}
