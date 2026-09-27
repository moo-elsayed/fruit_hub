import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/widgets/custom_arrow_back.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/reviews/presentation/managers/add_review_cubit/add_review_cubit.dart';
import 'package:fruit_hub/features/reviews/presentation/managers/reviews_cubit/reviews_cubit.dart';
import 'package:fruit_hub/features/reviews/presentation/views/reviews_view.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/add_review_bottom_sheet.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/empty_reviews_widget.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/rating_summary_card.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/review_card.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/review_status_banner.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockReviewsCubit extends MockCubit<ReviewsState>
    implements ReviewsCubit {}

class MockAddReviewCubit extends MockCubit<AddReviewState>
    implements AddReviewCubit {}

class MockUserInfoCubit extends MockCubit<UserInfoState>
    implements UserInfoCubit {}

void main() {
  late MockReviewsCubit mockReviewsCubit;
  late MockAddReviewCubit mockAddReviewCubit;
  late MockUserInfoCubit mockUserInfoCubit;

  const tFruit = FruitEntity(
    name: 'فراولة',
    code: 'strawberry_01',
    price: 35.0,
    avgRating: 4.5,
    ratingCount: 2,
  );

  const tReviews = [
    ReviewEntity(
      name: 'أحمد علي',
      image: '',
      description: 'فراولة طازجة ولذيذة جداً',
      date: '2026-09-20T10:00:00.000',
      rating: 5.0,
      userId: 'user_1',
    ),
    ReviewEntity(
      name: 'سارة محمد',
      image: '',
      description: 'جيدة ولكن الحجم متوسط',
      date: '2026-09-21T12:00:00.000',
      rating: 4.0,
      userId: 'user_2',
    ),
  ];

  setUp(() {
    mockReviewsCubit = MockReviewsCubit();
    mockAddReviewCubit = MockAddReviewCubit();
    mockUserInfoCubit = MockUserInfoCubit();

    when(() => mockReviewsCubit.fruit).thenReturn(tFruit);
    when(() => mockReviewsCubit.reviews).thenReturn(tReviews);
    when(() => mockReviewsCubit.avgRating).thenReturn(4.5);
    when(() => mockReviewsCubit.ratingCount).thenReturn(2);

    when(() => mockAddReviewCubit.state).thenReturn(AddReviewInitial());
    when(() => mockUserInfoCubit.currentUser)
        .thenReturn(const UserEntity(uid: 'user_test', name: 'مستخدم تجريبي'));

    if (getIt.isRegistered<AddReviewCubit>()) {
      getIt.unregister<AddReviewCubit>();
    }
    getIt.registerFactory<AddReviewCubit>(() => mockAddReviewCubit);
  });

  tearDown(() {
    if (getIt.isRegistered<AddReviewCubit>()) {
      getIt.unregister<AddReviewCubit>();
    }
  });

  Widget buildTestWidget({required ReviewsState state}) {
    when(() => mockReviewsCubit.state).thenReturn(state);

    return createWidgetForTesting(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ReviewsCubit>.value(value: mockReviewsCubit),
          BlocProvider<UserInfoCubit>.value(value: mockUserInfoCubit),
        ],
        child: const ReviewsView(fruit: tFruit),
      ),
    );
  }

  group('ReviewsView Header & List Rendering Tests', () {
    testWidgets(
      'should render CustomAppBar with localized fruit title and RatingSummaryCard',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            state: const ReviewsState(
              reviews: tReviews,
              avgRating: 4.5,
              ratingCount: 2,
              isCheckingEligibility: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('${tFruit.name} - ${AppStrings.reviews}'),
          findsOneWidget,
        );
        expect(find.byType(CustomArrowBack), findsOneWidget);
        expect(find.byType(RatingSummaryCard), findsOneWidget);
      },
    );

    testWidgets(
      'should render ReviewCard for each review when reviews list is not empty',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            state: const ReviewsState(
              reviews: tReviews,
              avgRating: 4.5,
              ratingCount: 2,
              isCheckingEligibility: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ReviewCard), findsNWidgets(2));
        expect(find.text('أحمد علي'), findsOneWidget);
        expect(find.text('سارة محمد'), findsOneWidget);
        expect(find.byType(EmptyReviewsWidget), findsNothing);
      },
    );

    testWidgets('should render EmptyReviewsWidget when reviews list is empty', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          state: const ReviewsState(
            reviews: [],
            avgRating: 0.0,
            ratingCount: 0,
            isCheckingEligibility: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(EmptyReviewsWidget), findsOneWidget);
      expect(find.byType(ReviewCard), findsNothing);
    });

    testWidgets(
      'should pop with updated fruit when CustomArrowBack is tapped',
      (WidgetTester tester) async {
        // Arrange
        FruitEntity? poppedFruit;

        await tester.pumpWidget(
          createWidgetForTesting(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  poppedFruit = await Navigator.of(context).push<FruitEntity>(
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider<ReviewsCubit>.value(
                            value: mockReviewsCubit,
                          ),
                          BlocProvider<UserInfoCubit>.value(
                            value: mockUserInfoCubit,
                          ),
                        ],
                        child: const ReviewsView(fruit: tFruit),
                      ),
                    ),
                  );
                },
                child: const Text('Open Reviews'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        when(() => mockReviewsCubit.state).thenReturn(
          const ReviewsState(
            reviews: tReviews,
            avgRating: 4.5,
            ratingCount: 2,
            isCheckingEligibility: false,
          ),
        );

        // Act - Open ReviewsView
        await tester.tap(find.text('Open Reviews'));
        await tester.pumpAndSettle();
        expect(find.byType(ReviewsView), findsOneWidget);

        // Act - Tap back button
        await tester.tap(find.byType(CustomArrowBack));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ReviewsView), findsNothing);
        expect(poppedFruit, isNotNull);
        expect(poppedFruit?.avgRating, equals(4.5));
        expect(poppedFruit?.ratingCount, equals(2));
      },
    );
  });

  group('ReviewsView Bottom Navigation Eligibility Tests', () {
    testWidgets('should hide bottom bar when isCheckingEligibility is true', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(state: const ReviewsState(isCheckingEligibility: true)),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CustomMaterialButton), findsNothing);
      expect(find.byType(ReviewStatusBanner), findsNothing);
    });

    testWidgets(
      'should render alreadyReviewed banner when hasAlreadyReviewed is true',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            state: const ReviewsState(
              isCheckingEligibility: false,
              hasAlreadyReviewed: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ReviewStatusBanner), findsOneWidget);
        expect(find.text(AppStrings.alreadyReviewedProduct), findsOneWidget);
        expect(find.byType(CustomMaterialButton), findsNothing);
      },
    );

    testWidgets(
      'should render write review button when user is a verified buyer and has not reviewed yet',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            state: const ReviewsState(
              isCheckingEligibility: false,
              hasAlreadyReviewed: false,
              isVerifiedBuyer: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CustomMaterialButton), findsOneWidget);
        expect(find.text(AppStrings.writeReview), findsOneWidget);
        expect(find.byType(ReviewStatusBanner), findsNothing);
      },
    );

    testWidgets(
      'should open AddReviewBottomSheet when write review button is tapped',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            state: const ReviewsState(
              isCheckingEligibility: false,
              hasAlreadyReviewed: false,
              isVerifiedBuyer: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text(AppStrings.writeReview));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AddReviewBottomSheet), findsOneWidget);
      },
    );

    testWidgets(
      'should render onlyBuyersCanReview banner when user is not a verified buyer',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            state: const ReviewsState(
              isCheckingEligibility: false,
              hasAlreadyReviewed: false,
              isVerifiedBuyer: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ReviewStatusBanner), findsOneWidget);
        expect(find.text(AppStrings.onlyBuyersCanReview), findsOneWidget);
        expect(find.byType(CustomMaterialButton), findsNothing);
      },
    );
  });
}
