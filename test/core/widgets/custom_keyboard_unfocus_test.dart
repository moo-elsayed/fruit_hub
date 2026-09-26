import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/widgets/custom_keyboard_unfocus.dart';

import '../../helpers/test_widget_wrapper.dart';

void main() {
  group('CustomKeyboardUnfocus Widget Tests', () {
    testWidgets('should unfocus current primary focus when tapped outside', (
      WidgetTester tester,
    ) async {
      // Arrange
      final focusNode = FocusNode();

      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomKeyboardUnfocus(
            child: Column(
              children: [
                TextField(focusNode: focusNode),
                Container(
                  color: Colors.white,
                  height: 100,
                  width: 200,
                  key: const Key('outside_area'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act 1 - Request focus
      focusNode.requestFocus();
      await tester.pumpAndSettle();
      expect(focusNode.hasFocus, isTrue);

      // Act 2 - Tap outside
      await tester.tap(find.byKey(const Key('outside_area')));
      await tester.pumpAndSettle();

      // Assert
      expect(focusNode.hasFocus, isFalse);
    });
  });
}
