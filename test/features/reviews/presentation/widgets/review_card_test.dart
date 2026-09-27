import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/review_card.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  const dummyReviewWithImage = ReviewEntity(
    name: 'كريم محمود',
    image: 'https://example.com/avatar.jpg',
    description: 'منتج رائع وطازج جداً وسرعة في التوصيل',
    date: '2026-09-25T14:30:00.000',
    rating: 5.0,
    userId: 'u10',
  );

  const dummyReviewWithoutImage = ReviewEntity(
    name: 'ياسمين',
    image: '',
    description: 'جيد ومقبول',
    date: '2026-09-26T09:15:00.000',
    rating: 3.5,
    userId: 'u11',
  );

  const dummyReviewAnonymous = ReviewEntity(
    name: '  ',
    image: '',
    description: 'بدون اسم',
    date: '2026-09-27T10:00:00.000',
    rating: 4.0,
    userId: 'u12',
  );

  group('ReviewCard Widget Tests', () {
    testWidgets(
      'should render user name, description, rating, and verified purchase badge',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const ReviewCard(review: dummyReviewWithImage),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.text('كريم محمود'), findsOneWidget);
        expect(
          find.text('منتج رائع وطازج جداً وسرعة في التوصيل'),
          findsOneWidget,
        );
        expect(find.text('5.0'), findsOneWidget);
        expect(find.text(AppStrings.verifiedPurchase), findsOneWidget);
        expect(find.byType(CachedNetworkImage), findsOneWidget);
      },
    );

    testWidgets('should render initials avatar when image is empty', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const ReviewCard(review: dummyReviewWithoutImage),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('ياسمين'), findsOneWidget);
      expect(find.text('ي'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets(
      'should render anonymous user string when name is empty or whitespace',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const ReviewCard(review: dummyReviewAnonymous),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.text(AppStrings.anonymousUser), findsOneWidget);
        expect(find.text('U'), findsOneWidget);
      },
    );
  });
}
