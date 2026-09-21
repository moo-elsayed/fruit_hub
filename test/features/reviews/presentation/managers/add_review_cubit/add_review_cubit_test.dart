import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/reviews/domain/use_cases/add_review_use_case.dart';
import 'package:fruit_hub/features/reviews/presentation/managers/add_review_cubit/add_review_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAddReviewUseCase extends Mock implements AddReviewUseCase {}

class FakeReviewEntity extends Fake implements ReviewEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeReviewEntity());
  });

  late MockAddReviewUseCase mockAddReviewUseCase;
  late AddReviewCubit sut;

  const tProductCode = 'FRUIT_ORANGE_01';
  const tErrorMessage = 'Failed to submit review';
  const tServerFailure = ServerFailure(error: tErrorMessage);

  const tReviewEntity = ReviewEntity(
    name: 'سارة',
    image: 'sara.png',
    description: 'فاكهة طازجة وتوصيل سريع',
    date: '2026-09-21',
    rating: 5.0,
    userId: 'user_123',
  );

  setUp(() {
    mockAddReviewUseCase = MockAddReviewUseCase();
    sut = AddReviewCubit(mockAddReviewUseCase);
  });

  tearDown(() {
    sut.close();
  });

  test('initial state should be AddReviewInitial', () {
    // Assert
    expect(sut.state, isA<AddReviewInitial>());
  });

  group('submitReview', () {
    blocTest<AddReviewCubit, AddReviewState>(
      'should emit [AddReviewLoading, AddReviewSuccess] with reviewEntity when use case returns NetworkSuccess',
      build: () => sut,
      setUp: () {
        // Arrange
        when(
          () => mockAddReviewUseCase(
            productCode: any(named: 'productCode'),
            reviewEntity: any(named: 'reviewEntity'),
          ),
        ).thenAnswer((_) async => const NetworkSuccess<void>());
      },
      act: (cubit) async {
        // Act
        await cubit.submitReview(
          productCode: tProductCode,
          reviewEntity: tReviewEntity,
        );
      },
      expect: () => [
        isA<AddReviewLoading>(),
        isA<AddReviewSuccess>().having(
          (state) => state.newReview,
          'newReview',
          tReviewEntity,
        ),
      ],
      verify: (_) {
        // Assert
        verify(
          () => mockAddReviewUseCase(
            productCode: tProductCode,
            reviewEntity: tReviewEntity,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockAddReviewUseCase);
      },
    );

    blocTest<AddReviewCubit, AddReviewState>(
      'should emit [AddReviewLoading, AddReviewFailure] with error message when use case returns NetworkFailure',
      build: () => sut,
      setUp: () {
        // Arrange
        when(
          () => mockAddReviewUseCase(
            productCode: any(named: 'productCode'),
            reviewEntity: any(named: 'reviewEntity'),
          ),
        ).thenAnswer((_) async => const NetworkFailure<void>(tServerFailure));
      },
      act: (cubit) async {
        // Act
        await cubit.submitReview(
          productCode: tProductCode,
          reviewEntity: tReviewEntity,
        );
      },
      expect: () => [
        isA<AddReviewLoading>(),
        isA<AddReviewFailure>().having(
          (state) => state.errorMessage,
          'errorMessage',
          tErrorMessage,
        ),
      ],
      verify: (_) {
        // Assert
        verify(
          () => mockAddReviewUseCase(
            productCode: tProductCode,
            reviewEntity: tReviewEntity,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockAddReviewUseCase);
      },
    );
  });
}
