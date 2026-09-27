import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/rating_summary_card.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  const dummyReviews = [
    ReviewEntity(
      name: 'User 1',
      image: '',
      description: 'Review 1',
      date: '2026-09-20',
      rating: 5.0,
      userId: 'u1',
    ),
    ReviewEntity(
      name: 'User 2',
      image: '',
      description: 'Review 2',
      date: '2026-09-21',
      rating: 4.0,
      userId: 'u2',
    ),
    ReviewEntity(
      name: 'User 3',
      image: '',
      description: 'Review 3',
      date: '2026-09-22',
      rating: 5.0,
      userId: 'u3',
    ),
  ];

  group('RatingSummaryCard Widget Tests', () {
    testWidgets(
      'should render formatted average rating, star icons, and total reviews count',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const RatingSummaryCard(
              avgRating: 4.7,
              ratingCount: 3,
              reviews: dummyReviews,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('4.7'), findsOneWidget);
        expect(find.text('3 ${AppStrings.reviews}'), findsOneWidget);
        expect(find.byIcon(Icons.star_rounded), findsWidgets);
      },
    );

    testWidgets('should render breakdown star labels from 5 down to 1', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const RatingSummaryCard(
            avgRating: 4.7,
            ratingCount: 3,
            reviews: dummyReviews,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('5'), findsWidgets);
      expect(find.text('4'), findsWidgets);
      expect(find.text('3'), findsWidgets);
      expect(find.text('2'), findsWidgets);
      expect(find.text('1'), findsWidgets);
    });

    testWidgets(
      'should render zero state cleanly without errors when reviews list is empty',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const RatingSummaryCard(
              avgRating: 0.0,
              ratingCount: 0,
              reviews: [],
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('0.0'), findsOneWidget);
        expect(find.text('0 ${AppStrings.reviews}'), findsOneWidget);
      },
    );
  });
}
