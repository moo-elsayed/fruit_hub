import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/reviews/domain/repo/reviews_repo.dart';
import 'package:fruit_hub/features/reviews/domain/use_cases/add_review_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewsRepo extends Mock implements ReviewsRepo {}

class FakeReviewEntity extends Fake implements ReviewEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeReviewEntity());
  });

  late MockReviewsRepo mockReviewsRepo;
  late AddReviewUseCase sut;

  const tProductCode = 'FRUIT_ORANGE_01';
  const tServerFailure = ServerFailure(error: 'Failed to add review');

  const tReviewEntity = ReviewEntity(
    name: 'سارة',
    image: 'assets/images/sara.png',
    description: 'فاكهة طازجة وتوصيل سريع',
    date: '2026-09-20',
    rating: 4.8,
    userId: 'user_sara_123',
  );

  setUp(() {
    mockReviewsRepo = MockReviewsRepo();
    sut = AddReviewUseCase(mockReviewsRepo);
  });

  test(
    'should call addReview on ReviewsRepo with correct productCode and reviewEntity and return NetworkSuccess',
    () async {
      // Arrange
      when(
        () => mockReviewsRepo.addReview(
          productCode: any(named: 'productCode'),
          reviewEntity: any(named: 'reviewEntity'),
        ),
      ).thenAnswer((_) async => const NetworkSuccess<void>());

      // Act
      final result = await sut(
        productCode: tProductCode,
        reviewEntity: tReviewEntity,
      );

      // Assert
      expect(result, isA<NetworkSuccess<void>>());
      verify(
        () => mockReviewsRepo.addReview(
          productCode: tProductCode,
          reviewEntity: tReviewEntity,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockReviewsRepo);
    },
  );

  test(
    'should return NetworkFailure when ReviewsRepo fails during addReview',
    () async {
      // Arrange
      when(
        () => mockReviewsRepo.addReview(
          productCode: any(named: 'productCode'),
          reviewEntity: any(named: 'reviewEntity'),
        ),
      ).thenAnswer((_) async => const NetworkFailure<void>(tServerFailure));

      // Act
      final result = await sut(
        productCode: tProductCode,
        reviewEntity: tReviewEntity,
      );

      // Assert
      expect(result, isA<NetworkFailure<void>>());
      final failure = (result as NetworkFailure<void>).failure;
      expect(failure.error, tServerFailure.error);
      verify(
        () => mockReviewsRepo.addReview(
          productCode: tProductCode,
          reviewEntity: tReviewEntity,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockReviewsRepo);
    },
  );
}
