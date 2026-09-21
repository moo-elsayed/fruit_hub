import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/models/review_model.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/reviews/data/data_sources/remote/reviews_remote_data_source.dart';
import 'package:fruit_hub/features/reviews/data/repo_imp/reviews_repo_imp.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewsRemoteDataSource extends Mock
    implements ReviewsRemoteDataSource {}

class FakeReviewModel extends Fake implements ReviewModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeReviewModel());
  });

  late MockReviewsRemoteDataSource mockRemoteDataSource;
  late ReviewsRepoImp sut;

  const tProductCode = 'FRUIT_MANGO_01';
  const tServerFailure = ServerFailure(error: 'Operation failed');

  const tReviewEntity = ReviewEntity(
    name: 'أحمد',
    image: 'assets/images/ahmed.png',
    description: 'فاكهة طازجة ولذيذة جداً',
    date: '2026-09-20',
    rating: 5.0,
    userId: 'user_123',
  );

  setUp(() {
    mockRemoteDataSource = MockReviewsRemoteDataSource();
    sut = ReviewsRepoImp(mockRemoteDataSource);
  });

  group('checkUserPurchasedProduct', () {
    test(
      'should call remoteDataSource.checkUserPurchasedProduct with correct productCode and return NetworkSuccess(true)',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.checkUserPurchasedProduct(
            productCode: any(named: 'productCode'),
          ),
        ).thenAnswer((_) async => const NetworkSuccess(true));

        // Act
        final result = await sut.checkUserPurchasedProduct(
          productCode: tProductCode,
        );

        // Assert
        expect(result, isA<NetworkSuccess<bool>>());
        final isPurchased = (result as NetworkSuccess<bool>).data;
        expect(isPurchased, isTrue);
        verify(
          () => mockRemoteDataSource.checkUserPurchasedProduct(
            productCode: tProductCode,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should call remoteDataSource.checkUserPurchasedProduct with correct productCode and return NetworkSuccess(false)',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.checkUserPurchasedProduct(
            productCode: any(named: 'productCode'),
          ),
        ).thenAnswer((_) async => const NetworkSuccess(false));

        // Act
        final result = await sut.checkUserPurchasedProduct(
          productCode: tProductCode,
        );

        // Assert
        expect(result, isA<NetworkSuccess<bool>>());
        final isPurchased = (result as NetworkSuccess<bool>).data;
        expect(isPurchased, isFalse);
        verify(
          () => mockRemoteDataSource.checkUserPurchasedProduct(
            productCode: tProductCode,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remoteDataSource fails',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.checkUserPurchasedProduct(
            productCode: any(named: 'productCode'),
          ),
        ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

        // Act
        final result = await sut.checkUserPurchasedProduct(
          productCode: tProductCode,
        );

        // Assert
        expect(result, isA<NetworkFailure<bool>>());
        final failure = (result as NetworkFailure<bool>).failure;
        expect(failure.error, tServerFailure.error);
        verify(
          () => mockRemoteDataSource.checkUserPurchasedProduct(
            productCode: tProductCode,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );
  });

  group('addReview', () {
    test(
      'should map ReviewEntity to ReviewModel, call remoteDataSource.addReview, and return NetworkSuccess',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.addReview(
            productCode: any(named: 'productCode'),
            reviewModel: any(named: 'reviewModel'),
          ),
        ).thenAnswer((_) async => const NetworkSuccess<void>());

        // Act
        final result = await sut.addReview(
          productCode: tProductCode,
          reviewEntity: tReviewEntity,
        );

        // Assert
        expect(result, isA<NetworkSuccess<void>>());

        final captured =
            verify(
                  () => mockRemoteDataSource.addReview(
                    productCode: tProductCode,
                    reviewModel: captureAny(named: 'reviewModel'),
                  ),
                ).captured.single
                as ReviewModel;

        expect(captured.name, tReviewEntity.name);
        expect(captured.image, tReviewEntity.image);
        expect(captured.description, tReviewEntity.description);
        expect(captured.date, tReviewEntity.date);
        expect(captured.rating, tReviewEntity.rating);
        expect(captured.userId, tReviewEntity.userId);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should return NetworkFailure when remoteDataSource fails during addReview',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.addReview(
            productCode: any(named: 'productCode'),
            reviewModel: any(named: 'reviewModel'),
          ),
        ).thenAnswer((_) async => const NetworkFailure<void>(tServerFailure));

        // Act
        final result = await sut.addReview(
          productCode: tProductCode,
          reviewEntity: tReviewEntity,
        );

        // Assert
        expect(result, isA<NetworkFailure<void>>());
        final failure = (result as NetworkFailure<void>).failure;
        expect(failure.error, tServerFailure.error);
        verify(
          () => mockRemoteDataSource.addReview(
            productCode: tProductCode,
            reviewModel: any(named: 'reviewModel'),
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );
  });
}
