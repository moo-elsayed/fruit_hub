import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/helpers/network_response.dart';
import 'package:fruit_hub/core/services/local_storage/local_storage_service.dart';
import 'package:fruit_hub/features/home/domain/use_cases/get_best_seller_products_use_case.dart';
import 'package:fruit_hub/features/home/presentation/managers/home_cubit/home_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGetBestSellerProductsUseCase extends Mock
    implements GetBestSellerProductsUseCase {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late HomeCubit sut;
  late MockGetBestSellerProductsUseCase mockGetBestSellerProductsUseCase;
  late MockLocalStorageService mockLocalStorageService;

  List<FruitEntity> fruits = [FruitEntity(), FruitEntity(), FruitEntity()];

  final tSuccessResponse = NetworkSuccess<List<FruitEntity>>(fruits);
  final tFailureResponse = NetworkFailure<List<FruitEntity>>(
    Exception("permission-denied"),
  );
  const tUsername = "Test User";

  setUp(() {
    mockGetBestSellerProductsUseCase = MockGetBestSellerProductsUseCase();
    mockLocalStorageService = MockLocalStorageService();
    sut = HomeCubit(mockGetBestSellerProductsUseCase, mockLocalStorageService);
  });

  group("HomeCubit", () {
    test('initial state should be HomeInitial', () {
      expect(sut.state, isA<HomeInitial>());
    });

    blocTest<HomeCubit, HomeState>(
      'emits [GetBestSellerProductsLoading, GetBestSellerProductsSuccess] when getBestSellerProducts is successful',
      build: () => sut,
      setUp: () {
        when(
          () => mockGetBestSellerProductsUseCase.call(),
        ).thenAnswer((_) async => tSuccessResponse);
      },
      act: (bloc) => sut.getBestSellerProducts(),
      expect: () => [
        isA<GetBestSellerProductsLoading>(),
        isA<GetBestSellerProductsSuccess>().having(
          (s) => s.fruits,
          'fruits',
          equals(fruits),
        ),
      ],
      verify: (_) {
        verify(() => mockGetBestSellerProductsUseCase.call()).called(1);
        verifyNoMoreInteractions(mockGetBestSellerProductsUseCase);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'emits [GetBestSellerProductsLoading, GetBestSellerProductsFailure] when getBestSellerProducts is unsuccessful',
      build: () => sut,
      setUp: () {
        when(
          () => mockGetBestSellerProductsUseCase.call(),
        ).thenAnswer((_) async => tFailureResponse);
      },
      act: (bloc) => sut.getBestSellerProducts(),
      expect: () => [
        isA<GetBestSellerProductsLoading>(),
        isA<GetBestSellerProductsFailure>().having(
          (s) => s.error,
          'exception',
          equals(getErrorMessage(tFailureResponse)),
        ),
      ],
      verify: (_) {
        verify(() => mockGetBestSellerProductsUseCase.call()).called(1);
        verifyNoMoreInteractions(mockGetBestSellerProductsUseCase);
      },
    );

    test('should get username from localStorage', () {
      // Arrange
      when(() => mockLocalStorageService.getUsername()).thenReturn(tUsername);

      // Act
      var userName = sut.getUserName();

      // Assert
      expect(userName, tUsername);
      verify(() => mockLocalStorageService.getUsername()).called(1);
      verifyNoMoreInteractions(mockLocalStorageService);
    });
  });
}
