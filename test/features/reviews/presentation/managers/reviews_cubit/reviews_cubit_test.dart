import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/errors/failures.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/reviews/domain/use_cases/check_user_purchased_product_use_case.dart';
import 'package:fruit_hub/features/reviews/presentation/managers/reviews_cubit/reviews_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckUserPurchasedProductUseCase extends Mock
    implements CheckUserPurchasedProductUseCase {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockCheckUserPurchasedProductUseCase mockCheckPurchasedUseCase;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late ReviewsCubit sut;

  const tUserId = 'user_123';
  const tProductCode = 'FRUIT_APPLE_01';

  const tInitialReview = ReviewEntity(
    name: 'سارة',
    image: 'sara.png',
    description: 'جيد جداً',
    date: '2026-09-01',
    rating: 4.0,
    userId: 'other_user',
  );

  const tFruit = FruitEntity(
    name: 'تفاح',
    code: tProductCode,
    price: 20.0,
    avgRating: 4.0,
    ratingCount: 1,
    reviews: [tInitialReview],
  );

  setUp(() {
    mockCheckPurchasedUseCase = MockCheckUserPurchasedProductUseCase();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn(tUserId);
    when(() => mockAuth.currentUser).thenReturn(null);
    when(
      () => mockCheckPurchasedUseCase(productCode: any(named: 'productCode')),
    ).thenAnswer((_) async => const NetworkSuccess(false));
  });

  tearDown(() {
    sut.close();
  });

  ReviewsCubit createCubit({FruitEntity? fruit}) {
    sut = ReviewsCubit(
      checkUserPurchasedProductUseCase: mockCheckPurchasedUseCase,
      fruit: fruit ?? tFruit,
      auth: mockAuth,
    );
    return sut;
  }

  group('initialization', () {
    test('initial state should contain initial fruit reviews and ratings', () {
      // Act
      createCubit();

      // Assert
      expect(sut.state.reviews, tFruit.reviews);
      expect(sut.state.avgRating, tFruit.avgRating);
      expect(sut.state.ratingCount, tFruit.ratingCount);
    });

    test('should finish checking eligibility with isVerifiedBuyer false when currentUser is null', () {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      createCubit();

      // Assert
      expect(sut.state.isCheckingEligibility, isFalse);
      expect(sut.state.isVerifiedBuyer, isFalse);
      expect(sut.state.hasAlreadyReviewed, isFalse);
    });

    blocTest<ReviewsCubit, ReviewsState>(
      'should check eligibility and set isVerifiedBuyer true when purchase check succeeds',
      setUp: () {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockCheckPurchasedUseCase(productCode: tProductCode))
            .thenAnswer((_) async => const NetworkSuccess(true));
      },
      build: () => createCubit(),
      expect: () => [
        isA<ReviewsState>()
            .having(
              (s) => s.isCheckingEligibility,
              'isCheckingEligibility',
              isFalse,
            )
            .having((s) => s.isVerifiedBuyer, 'isVerifiedBuyer', isTrue)
            .having((s) => s.hasAlreadyReviewed, 'hasAlreadyReviewed', isFalse),
      ],
      verify: (_) {
        // Assert
        verify(() => mockCheckPurchasedUseCase(productCode: tProductCode))
            .called(1);
      },
    );

    blocTest<ReviewsCubit, ReviewsState>(
      'should set isVerifiedBuyer false when purchase check returns failure',
      setUp: () {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockCheckPurchasedUseCase(productCode: tProductCode))
            .thenAnswer(
              (_) async => const NetworkFailure(
                ServerFailure(error: 'Failed to verify purchase'),
              ),
            );
      },
      build: () => createCubit(),
      expect: () => [
        isA<ReviewsState>()
            .having(
              (s) => s.isCheckingEligibility,
              'isCheckingEligibility',
              isFalse,
            )
            .having((s) => s.isVerifiedBuyer, 'isVerifiedBuyer', isFalse)
            .having((s) => s.hasAlreadyReviewed, 'hasAlreadyReviewed', isFalse),
      ],
    );

    blocTest<ReviewsCubit, ReviewsState>(
      'should detect if currentUser has already reviewed the fruit by userId',
      setUp: () {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockCheckPurchasedUseCase(productCode: tProductCode))
            .thenAnswer((_) async => const NetworkSuccess(true));
      },
      build: () {
        const reviewedFruit = FruitEntity(
          name: 'تفاح',
          code: tProductCode,
          reviews: [ReviewEntity(name: 'أي اسم', userId: tUserId, rating: 5.0)],
        );
        return createCubit(fruit: reviewedFruit);
      },
      expect: () => [
        isA<ReviewsState>()
            .having(
              (s) => s.isCheckingEligibility,
              'isCheckingEligibility',
              isFalse,
            )
            .having((s) => s.isVerifiedBuyer, 'isVerifiedBuyer', isTrue)
            .having((s) => s.hasAlreadyReviewed, 'hasAlreadyReviewed', isTrue),
      ],
    );
  });

  group('addReviewLocally', () {
    const tNewReview = ReviewEntity(
      name: 'علي',
      image: 'ali.png',
      description: 'ممتاز جداً',
      date: '2026-09-21',
      rating: 5.0,
      userId: tUserId,
    );

    blocTest<ReviewsCubit, ReviewsState>(
      'should prepend new review, recalculate avgRating, and update ratingCount',
      build: () => createCubit(),
      act: (cubit) => cubit.addReviewLocally(tNewReview),
      expect: () => [
        isA<ReviewsState>()
            .having((s) => s.reviews, 'reviews length', hasLength(2))
            .having((s) => s.reviews.first, 'first review', tNewReview)
            .having((s) => s.ratingCount, 'ratingCount', 2)
            .having((s) => s.avgRating, 'avgRating', 4.5)
            .having((s) => s.hasAlreadyReviewed, 'hasAlreadyReviewed', isTrue),
      ],
    );

    blocTest<ReviewsCubit, ReviewsState>(
      'should correctly round avgRating to single decimal place when average is recurring',
      build: () {
        const initialTwoReviewsFruit = FruitEntity(
          name: 'تفاح',
          code: tProductCode,
          avgRating: 4.0,
          ratingCount: 2,
          reviews: [
            ReviewEntity(name: 'مستخدم 1', rating: 4.0),
            ReviewEntity(name: 'مستخدم 2', rating: 4.0),
          ],
        );
        return createCubit(fruit: initialTwoReviewsFruit);
      },
      act: (cubit) => cubit.addReviewLocally(tNewReview),
      expect: () => [
        isA<ReviewsState>()
            .having((s) => s.ratingCount, 'ratingCount', 3)
            .having((s) => s.avgRating, 'avgRating', 4.3),
      ],
    );
  });
}
