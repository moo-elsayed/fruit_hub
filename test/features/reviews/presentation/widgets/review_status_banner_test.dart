import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/reviews/presentation/widgets/review_status_banner.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('ReviewStatusBanner Widget Tests', () {
    testWidgets('should render icon and message text accurately', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: Scaffold(
            bottomNavigationBar: ReviewStatusBanner(
              icon: Icons.verified_user_outlined,
              message: AppStrings.onlyBuyersCanReview,
              color: Colors.grey,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.verified_user_outlined), findsOneWidget);
      expect(find.text(AppStrings.onlyBuyersCanReview), findsOneWidget);
    });
  });
}
