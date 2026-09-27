import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/empty_reviews_widget.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('EmptyReviewsWidget Widget Tests', () {
    testWidgets('should render no reviews title, subtitle, and star icon', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const Scaffold(body: EmptyReviewsWidget()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(AppStrings.noReviewsYet), findsOneWidget);
      expect(find.text(AppStrings.beTheFirstToReview), findsOneWidget);
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    });
  });
}
