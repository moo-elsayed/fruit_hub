import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/add_item_to_favorites_use_case.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/get_favorites_use_case.dart';
import 'package:fruit_hub/features/favorites/domain/use_cases/remove_item_from_favorites_use_case.dart';
import 'package:fruit_hub/features/favorites/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAddItemToFavoritesUseCase extends Mock
    implements AddItemToFavoritesUseCase {}

class MockRemoveItemFromFavoritesUseCase extends Mock
    implements RemoveItemFromFavoritesUseCase {}

class MockGetFavoritesUseCase extends Mock implements GetFavoritesUseCase {}

void main() {
  late MockAddItemToFavoritesUseCase mockAddItemToFavoritesUseCase;
  late MockRemoveItemFromFavoritesUseCase mockRemoveItemFromFavoritesUseCase;
  late MockGetFavoritesUseCase mockGetFavoritesUseCase;
  late FavoriteCubit sut;

  const tFruit1 = FruitEntity(
    code: 'prod_apple_01',
    name: 'تفاح أحمر',
    description: 'تفاح أحمر طازج',
    price: 25.0,
    imagePath: 'assets/images/apple_red.png',
    isFeatured: true,
    avgRating: 4.5,
    ratingCount: 15,
    isOrganic: true,
    daysUntilExpiration: 10,
    weightInGrams: 500,
    numberOfCalories: 52,
    reviews: [
      ReviewEntity(
        name: 'أحمد',
        image: 'assets/images/user1.png',
        description: 'ممتاز',
        date: '2026-09-01',
        rating: 5.0,
        userId: 'user_1',
      ),
    ],
  );

  const tFruit2 = FruitEntity(
    code: 'prod_banana_02',
    name: 'موز بلدي',
    description: 'موز طازج ومغذي',
    price: 15.0,
    imagePath: 'assets/images/banana.png',
    isFeatured: false,
    avgRating: 4.0,
    ratingCount: 5,
    isOrganic: true,
    daysUntilExpiration: 5,
    weightInGrams: 1000,
    numberOfCalories: 89,
    reviews: [],
  );

  setUp(() {
    mockAddItemToFavoritesUseCase = MockAddItemToFavoritesUseCase();
    mockRemoveItemFromFavoritesUseCase = MockRemoveItemFromFavoritesUseCase();
    mockGetFavoritesUseCase = MockGetFavoritesUseCase();

    sut = FavoriteCubit(
      mockAddItemToFavoritesUseCase,
      mockRemoveItemFromFavoritesUseCase,
      mockGetFavoritesUseCase,
    );
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be FavoriteInitial', () {
    // Assert
    expect(sut.state, isA<FavoriteInitial>());
    expect(sut.favoriteFruits, isEmpty);
  });

  group('getFavorites', () {
    blocTest<FavoriteCubit, FavoriteState>(
      'should emit [GetFavoritesLoading, GetFavoritesSuccess] and update favoriteFruits when use case succeeds',
      build: () {
        when(() => mockGetFavoritesUseCase.call())
            .thenAnswer((_) async => const NetworkSuccess([tFruit1, tFruit2]));
        return sut;
      },
      act: (cubit) => cubit.getFavorites(),
      expect: () => [
        isA<GetFavoritesLoading>(),
        isA<GetFavoritesSuccess>().having(
          (state) => state.favorites,
          'favorites',
          [tFruit1, tFruit2],
        ),
      ],
      verify: (cubit) {
        verify(() => mockGetFavoritesUseCase.call()).called(1);
        expect(cubit.favoriteFruits, [tFruit1, tFruit2]);
        expect(cubit.isFavorite(tFruit1.code), isTrue);
        expect(cubit.isFavorite(tFruit2.code), isTrue);
        expect(cubit.isFavorite('unknown_id'), isFalse);
      },
    );

    blocTest<FavoriteCubit, FavoriteState>(
      'should emit [GetFavoritesLoading, GetFavoritesFailure] when use case returns failure',
      build: () {
        when(() => mockGetFavoritesUseCase.call()).thenAnswer(
          (_) async => const NetworkFailure(
            ServerFailure(error: 'Failed to fetch favorites'),
          ),
        );
        return sut;
      },
      act: (cubit) => cubit.getFavorites(),
      expect: () => [
        isA<GetFavoritesLoading>(),
        isA<GetFavoritesFailure>().having(
          (state) => state.errorMessage,
          'errorMessage',
          'Failed to fetch favorites',
        ),
      ],
      verify: (cubit) {
        verify(() => mockGetFavoritesUseCase.call()).called(1);
        expect(cubit.favoriteFruits, isEmpty);
      },
    );

    blocTest<FavoriteCubit, FavoriteState>(
      'should emit [GetFavoritesSuccess] immediately without loading or network call when favorites are already cached',
      build: () {
        // Pre-populate favorites
        when(() => mockGetFavoritesUseCase.call())
            .thenAnswer((_) async => const NetworkSuccess([tFruit1]));
        return sut;
      },
      act: (cubit) async {
        await cubit.getFavorites();
        // Second call should return cached list
        await cubit.getFavorites();
      },
      expect: () => [
        isA<GetFavoritesLoading>(),
        isA<GetFavoritesSuccess>().having(
          (state) => state.favorites,
          'favorites',
          [tFruit1],
        ),
        isA<GetFavoritesSuccess>().having(
          (state) => state.favorites,
          'favorites',
          [tFruit1],
        ),
      ],
      verify: (cubit) {
        // Only called once from the first getFavorites()
        verify(() => mockGetFavoritesUseCase.call()).called(1);
      },
    );
  });

  group('toggleFavorite', () {
    blocTest<FavoriteCubit, FavoriteState>(
      'should optimistically add fruit to favorites and emit [ToggleFavoriteSuccess] when item is not favorite and remote call succeeds',
      build: () {
        when(() => mockAddItemToFavoritesUseCase.call(tFruit1.code))
            .thenAnswer((_) async => const NetworkSuccess(null));
        return sut;
      },
      act: (cubit) => cubit.toggleFavorite(tFruit1),
      expect: () => [
        isA<ToggleFavoriteSuccess>().having(
          (state) => state.favorites,
          'favorites',
          [tFruit1],
        ),
      ],
      verify: (cubit) {
        verify(() => mockAddItemToFavoritesUseCase.call(tFruit1.code))
            .called(1);
        expect(cubit.isFavorite(tFruit1.code), isTrue);
        expect(cubit.favoriteFruits, [tFruit1]);
      },
    );

    blocTest<FavoriteCubit, FavoriteState>(
      'should revert added fruit and emit [ToggleFavoriteSuccess, ToggleFavoriteFailure] when remote call fails',
      build: () {
        when(() => mockAddItemToFavoritesUseCase.call(tFruit1.code)).thenAnswer(
          (_) async => const NetworkFailure(
            ServerFailure(error: 'Network error adding favorite'),
          ),
        );
        return sut;
      },
      act: (cubit) => cubit.toggleFavorite(tFruit1),
      expect: () => [
        isA<ToggleFavoriteSuccess>(),
        isA<ToggleFavoriteFailure>().having(
          (state) => state.errorMessage,
          'errorMessage',
          'Network error adding favorite',
        ),
      ],
      verify: (cubit) {
        verify(() => mockAddItemToFavoritesUseCase.call(tFruit1.code))
            .called(1);
        expect(cubit.isFavorite(tFruit1.code), isFalse);
        expect(cubit.favoriteFruits, isEmpty);
      },
    );

    blocTest<FavoriteCubit, FavoriteState>(
      'should optimistically remove fruit from favorites and emit [ToggleFavoriteSuccess] when item is favorite and remote call succeeds',
      build: () {
        when(() => mockGetFavoritesUseCase.call())
            .thenAnswer((_) async => const NetworkSuccess([tFruit1, tFruit2]));
        when(() => mockRemoveItemFromFavoritesUseCase.call(tFruit1.code))
            .thenAnswer((_) async => const NetworkSuccess(null));
        return sut;
      },
      act: (cubit) async {
        await cubit.getFavorites();
        await cubit.toggleFavorite(tFruit1);
      },
      expect: () => [
        isA<GetFavoritesLoading>(),
        isA<GetFavoritesSuccess>(),
        isA<ToggleFavoriteSuccess>().having(
          (state) => state.favorites,
          'favorites',
          [tFruit2],
        ),
      ],
      verify: (cubit) {
        verify(() => mockRemoveItemFromFavoritesUseCase.call(tFruit1.code))
            .called(1);
        expect(cubit.isFavorite(tFruit1.code), isFalse);
        expect(cubit.isFavorite(tFruit2.code), isTrue);
        expect(cubit.favoriteFruits, [tFruit2]);
      },
    );

    blocTest<FavoriteCubit, FavoriteState>(
      'should revert removed fruit and emit [ToggleFavoriteFailure] when remote removal fails',
      build: () {
        when(() => mockGetFavoritesUseCase.call())
            .thenAnswer((_) async => const NetworkSuccess([tFruit1]));
        when(() => mockRemoveItemFromFavoritesUseCase.call(tFruit1.code))
            .thenAnswer(
              (_) async => const NetworkFailure(
                ServerFailure(error: 'Network error removing favorite'),
              ),
            );
        return sut;
      },
      act: (cubit) async {
        await cubit.getFavorites();
        await cubit.toggleFavorite(tFruit1);
      },
      expect: () => [
        isA<GetFavoritesLoading>(),
        isA<GetFavoritesSuccess>(),
        isA<ToggleFavoriteSuccess>(),
        isA<ToggleFavoriteFailure>().having(
          (state) => state.errorMessage,
          'errorMessage',
          'Network error removing favorite',
        ),
      ],
      verify: (cubit) {
        verify(() => mockRemoveItemFromFavoritesUseCase.call(tFruit1.code))
            .called(1);
        expect(cubit.isFavorite(tFruit1.code), isTrue);
        expect(cubit.favoriteFruits, [tFruit1]);
      },
    );
  });
}
