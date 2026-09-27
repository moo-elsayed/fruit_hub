import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/edit_profile_section_header.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('EditProfileSectionHeader Widget Tests', () {
    testWidgets('should render icon and title text correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: EditProfileSectionHeader(
            title: AppStrings.basicInfo,
            icon: Icons.person_outline_rounded,
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(find.text(AppStrings.basicInfo), findsOneWidget);
    });
  });
}
