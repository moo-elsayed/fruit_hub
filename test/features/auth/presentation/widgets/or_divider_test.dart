import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/or_divider.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('OrDivider Widget Tests', () {
    testWidgets(
      'should render or text and two dividers with theme border color',
      (WidgetTester tester) async {
        // Arrange
        late BuildContext capturedContext;
        await tester.pumpWidget(
          createWidgetForTesting(
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return const OrDivider();
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(AppStrings.or), findsOneWidget);
        final dividers = find.byType(Divider);
        expect(dividers, findsNWidgets(2));

        final firstDivider = tester.widget<Divider>(dividers.first);
        expect(firstDivider.color, equals(capturedContext.colors.border));

        final textWidget = tester.widget<Text>(find.text(AppStrings.or));
        expect(
          textWidget.style?.color,
          equals(capturedContext.colors.mainText),
        );
      },
    );
  });
}
