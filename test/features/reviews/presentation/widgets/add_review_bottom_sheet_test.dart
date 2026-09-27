import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_bottom_sheet_handle.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/interactive_rating_bar.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/reviews/presentation/managers/add_review_cubit/add_review_cubit.dart';
import 'package:fruit_hub/features/reviews/presentation/managers/reviews_cubit/reviews_cubit.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/add_review_bottom_sheet.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/add_review_rating_section.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockReviewsCubit extends MockCubit<ReviewsState>
    implements ReviewsCubit {}

class MockAddReviewCubit extends MockCubit<AddReviewState>
    implements AddReviewCubit {}

class MockUserInfoCubit extends MockCubit<UserInfoState>
    implements UserInfoCubit {}

class FakeReviewEntity extends Fake implements ReviewEntity {}

void main() {
  late MockReviewsCubit mockReviewsCubit;
  late MockAddReviewCubit mockAddReviewCubit;
  late MockUserInfoCubit mockUserInfoCubit;
  late StreamController<AddReviewState> addReviewStateController;

  const tFruit = FruitEntity(name: 'تفاح أحمر', code: 'apple_01', price: 30.0);

  const tUser = UserEntity(
    uid: 'user_456',
    name: 'محمد أحمد',
    image: 'https://example.com/avatar.jpg',
  );

  setUpAll(() {
    registerFallbackValue(FakeReviewEntity());
  });

  setUp(() {
    AppToast.isEnabled = false;
    addReviewStateController = StreamController<AddReviewState>.broadcast();
    mockReviewsCubit = MockReviewsCubit();
    mockAddReviewCubit = MockAddReviewCubit();
    mockUserInfoCubit = MockUserInfoCubit();

    when(() => mockReviewsCubit.fruit).thenReturn(tFruit);
    when(() => mockReviewsCubit.addReviewLocally(any())).thenReturn(null);

    when(() => mockAddReviewCubit.state).thenReturn(AddReviewInitial());
    when(() => mockAddReviewCubit.stream)
        .thenAnswer((_) => addReviewStateController.stream);
    when(
      () => mockAddReviewCubit.submitReview(
        productCode: any(named: 'productCode'),
        reviewEntity: any(named: 'reviewEntity'),
      ),
    ).thenAnswer((_) async {});

    when(() => mockUserInfoCubit.currentUser).thenReturn(tUser);
    when(() => mockUserInfoCubit.state).thenReturn(UserInfoSuccess(tUser));
  });

  tearDown(() {
    AppToast.isEnabled = true;
    addReviewStateController.close();
  });

  Widget buildTestWidget() => createWidgetForTesting(
    child: MultiBlocProvider(
      providers: [
        BlocProvider<ReviewsCubit>.value(value: mockReviewsCubit),
        BlocProvider<AddReviewCubit>.value(value: mockAddReviewCubit),
        BlocProvider<UserInfoCubit>.value(value: mockUserInfoCubit),
      ],
      child: const Scaffold(body: AddReviewBottomSheet()),
    ),
  );

  group('AddReviewBottomSheet Widget Tests', () {
    testWidgets(
      'should render all initial components: handle, title, rating, comment input, and submit button',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CustomBottomSheetHandle), findsOneWidget);
        expect(find.text(AppStrings.writeReview), findsOneWidget);
        expect(find.byType(AddReviewRatingSection), findsOneWidget);
        expect(find.text(AppStrings.writeYourReviewHere), findsOneWidget);
        expect(find.text(AppStrings.submitReview), findsOneWidget);
      },
    );

    testWidgets(
      'should submit review with correct rating, text, and user profile data when submit is tapped',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        const tComment = 'طعم رائع جداً وجودة ممتازة';

        // Act - Change rating to 4 stars
        final ratingBarFinder = find.byType(InteractiveRatingBar);
        expect(ratingBarFinder, findsOneWidget);
        final interactiveRatingBar = tester.widget<InteractiveRatingBar>(
          ratingBarFinder,
        );
        interactiveRatingBar.onRatingChanged?.call(4);
        await tester.pump();

        // Act - Enter comment
        await tester.enterText(find.byType(TextField), tComment);
        await tester.pump();

        // Act - Tap submit
        await tester.tap(find.text(AppStrings.submitReview));
        await tester.pump();

        // Assert
        verify(
          () => mockAddReviewCubit.submitReview(
            productCode: tFruit.code,
            reviewEntity: any(
              named: 'reviewEntity',
              that: isA<ReviewEntity>()
                  .having((r) => r.rating, 'rating', 4.0)
                  .having((r) => r.description, 'description', tComment)
                  .having((r) => r.name, 'name', tUser.name)
                  .having((r) => r.image, 'image', tUser.image)
                  .having((r) => r.userId, 'userId', tUser.uid),
            ),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'should show loading spinner on submit button when state is AddReviewLoading',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockAddReviewCubit.state).thenReturn(AddReviewLoading());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // Assert
        final button = tester.widget<CustomMaterialButton>(
          find.byType(CustomMaterialButton),
        );
        expect(button.isLoading, isTrue);
      },
    );

    testWidgets(
      'should call addReviewLocally and pop bottom sheet when AddReviewSuccess is emitted',
      (WidgetTester tester) async {
        // Arrange
        const newReview = ReviewEntity(
          name: 'محمد أحمد',
          image: 'https://example.com/avatar.jpg',
          description: 'ممتاز',
          date: '2026-09-27T10:00:00.000',
          rating: 5.0,
          userId: 'user_456',
        );

        // Host in a Navigator so context.pop() can be verified
        await tester.pumpWidget(
          createWidgetForTesting(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider<ReviewsCubit>.value(value: mockReviewsCubit),
                      BlocProvider<AddReviewCubit>.value(
                        value: mockAddReviewCubit,
                      ),
                      BlocProvider<UserInfoCubit>.value(
                        value: mockUserInfoCubit,
                      ),
                    ],
                    child: const AddReviewBottomSheet(),
                  ),
                ),
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open bottom sheet
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();
        expect(find.byType(AddReviewBottomSheet), findsOneWidget);

        // Act - Simulate Cubit state emission
        addReviewStateController.add(AddReviewSuccess(newReview));
        await tester.pump();
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockReviewsCubit.addReviewLocally(newReview)).called(1);
        expect(find.byType(AddReviewBottomSheet), findsNothing);
      },
    );
  });
}
