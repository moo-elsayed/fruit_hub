import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/reviews/domain/repo/reviews_repo.dart';
import 'package:fruit_hub/features/reviews/domain/use_cases/check_user_purchased_product_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockReviewsRepo extends Mock implements ReviewsRepo {}

void main() {
  late MockReviewsRepo mockReviewsRepo;
  late CheckUserPurchasedProductUseCase sut;

  const tProductCode = 'FRUIT_APPLE_01';
  const tServerFailure = ServerFailure(error: 'Failed to verify purchase');

  setUp(() {
    mockReviewsRepo = MockReviewsRepo();
    sut = CheckUserPurchasedProductUseCase(mockReviewsRepo);
  });

  test('should call checkUserPurchasedProduct on ReviewsRepo with correct productCode and return NetworkSuccess(true)', () async {
    // Arrange
    when(
      () => mockReviewsRepo.checkUserPurchasedProduct(
        productCode: any(named: 'productCode'),
      ),
    ).thenAnswer((_) async => const NetworkSuccess(true));

    // Act
    final result = await sut(productCode: tProductCode);

    // Assert
    expect(result, isA<NetworkSuccess<bool>>());
    final isPurchased = (result as NetworkSuccess<bool>).data;
    expect(isPurchased, isTrue);
    verify(
      () =>
          mockReviewsRepo.checkUserPurchasedProduct(productCode: tProductCode),
    ).called(1);
    verifyNoMoreInteractions(mockReviewsRepo);
  });

  test('should call checkUserPurchasedProduct on ReviewsRepo with correct productCode and return NetworkSuccess(false)', () async {
    // Arrange
    when(
      () => mockReviewsRepo.checkUserPurchasedProduct(
        productCode: any(named: 'productCode'),
      ),
    ).thenAnswer((_) async => const NetworkSuccess(false));

    // Act
    final result = await sut(productCode: tProductCode);

    // Assert
    expect(result, isA<NetworkSuccess<bool>>());
    final isPurchased = (result as NetworkSuccess<bool>).data;
    expect(isPurchased, isFalse);
    verify(
      () =>
          mockReviewsRepo.checkUserPurchasedProduct(productCode: tProductCode),
    ).called(1);
    verifyNoMoreInteractions(mockReviewsRepo);
  });

  test('should return NetworkFailure when ReviewsRepo fails', () async {
    // Arrange
    when(
      () => mockReviewsRepo.checkUserPurchasedProduct(
        productCode: any(named: 'productCode'),
      ),
    ).thenAnswer((_) async => const NetworkFailure(tServerFailure));

    // Act
    final result = await sut(productCode: tProductCode);

    // Assert
    expect(result, isA<NetworkFailure<bool>>());
    final failure = (result as NetworkFailure<bool>).failure;
    expect(failure.error, tServerFailure.error);
    verify(
      () =>
          mockReviewsRepo.checkUserPurchasedProduct(productCode: tProductCode),
    ).called(1);
    verifyNoMoreInteractions(mockReviewsRepo);
  });
}
