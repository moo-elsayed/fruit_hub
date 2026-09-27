import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/email_verification_status_badge.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('EmailVerificationStatusBadge Widget Tests', () {
    testWidgets(
      'should render verified icon and verified text when isVerified is true',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const EmailVerificationStatusBadge(isVerified: true),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
        expect(find.text(AppStrings.verifiedAccount), findsOneWidget);
        expect(find.byIcon(Icons.info_outline_rounded), findsNothing);
        expect(find.text(AppStrings.pleaseVerifyYourEmail), findsNothing);
      },
    );

    testWidgets(
      'should render info icon and unverified text when isVerified is false',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const EmailVerificationStatusBadge(isVerified: false),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
        expect(find.text(AppStrings.pleaseVerifyYourEmail), findsOneWidget);
        expect(find.byIcon(Icons.verified_rounded), findsNothing);
        expect(find.text(AppStrings.verifiedAccount), findsNothing);
      },
    );
  });
}
