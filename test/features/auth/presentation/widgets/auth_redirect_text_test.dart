import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/auth_redirect_text.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('AuthRedirectText Widget Tests', () {
    testWidgets(
      'should render question and action text correctly with respective colors',
      (WidgetTester tester) async {
        // Arrange
        late BuildContext capturedContext;
        await tester.pumpWidget(
          createWidgetForTesting(
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return const AuthRedirectText(
                  question: 'لا تمتلك حساب؟',
                  action: 'قم بإنشاء حساب',
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final textFinder = find.byType(Text);
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        final rootSpan = textWidget.textSpan as TextSpan;
        expect(rootSpan.children?.length, equals(3));

        final questionSpan = rootSpan.children![0] as TextSpan;
        final actionSpan = rootSpan.children![2] as TextSpan;

        expect(questionSpan.text, equals('لا تمتلك حساب؟'));
        expect(
          questionSpan.style?.color,
          equals(capturedContext.colors.subText),
        );

        expect(actionSpan.text, equals('قم بإنشاء حساب'));
        expect(actionSpan.style?.color, equals(capturedContext.colors.primary));
      },
    );

    testWidgets(
      'should invoke onTap callback when action text tap recognizer is triggered',
      (WidgetTester tester) async {
        // Arrange
        var isTapped = false;
        await tester.pumpWidget(
          createWidgetForTesting(
            child: AuthRedirectText(
              question: 'تمتلك حساب بالفعل؟',
              action: 'تسجيل دخول',
              onTap: () => isTapped = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act
        final textWidget = tester.widget<Text>(find.byType(Text));
        final rootSpan = textWidget.textSpan as TextSpan;
        final actionSpan = rootSpan.children![2] as TextSpan;
        final recognizer = actionSpan.recognizer as TapGestureRecognizer?;
        recognizer?.onTap?.call();

        // Assert
        expect(isTapped, isTrue);
      },
    );
  });
}
