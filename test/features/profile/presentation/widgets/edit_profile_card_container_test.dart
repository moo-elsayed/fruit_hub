import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/edit_profile_card_container.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('EditProfileCardContainer Widget Tests', () {
    testWidgets(
      'should render child widget inside styled container correctly',
      (WidgetTester tester) async {
        // Arrange
        const testKey = Key('child_widget');

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const EditProfileCardContainer(
              child: SizedBox(key: testKey, width: 50, height: 50),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byKey(testKey), findsOneWidget);
        expect(find.byType(EditProfileCardContainer), findsOneWidget);
      },
    );
  });
}
