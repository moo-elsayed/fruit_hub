import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/auth_header_section.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('AuthHeaderSection Widget Tests', () {
    testWidgets(
      'should render title, subtitle, and image badge when imagePath is provided',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const AuthHeaderSection(
              title: 'مرحبًا بك',
              subtitle: 'سجل دخولك الآن',
              imagePath: 'assets/images/app-logo.png',
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('مرحبًا بك'), findsOneWidget);
        expect(find.text('سجل دخولك الآن'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets(
      'should render title, subtitle, and icon badge when icon is provided',
      (WidgetTester tester) async {
        // Arrange
        late BuildContext capturedContext;
        await tester.pumpWidget(
          createWidgetForTesting(
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return const AuthHeaderSection(
                  title: 'حساب جديد',
                  subtitle: 'أنشئ حسابك',
                  icon: Icons.person_add_rounded,
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('حساب جديد'), findsOneWidget);
        expect(find.text('أنشئ حسابك'), findsOneWidget);

        final iconFinder = find.byIcon(Icons.person_add_rounded);
        expect(iconFinder, findsOneWidget);

        final iconWidget = tester.widget<Icon>(iconFinder);
        expect(iconWidget.color, equals(capturedContext.colors.primary));
      },
    );

    testWidgets('should render customBadge when customBadge is provided', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const AuthHeaderSection(
            title: 'إعادة تعيين كلمة المرور',
            subtitle: 'أدخل بريدك الإلكتروني',
            customBadge: SizedBox(key: ValueKey('custom_badge_key')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('إعادة تعيين كلمة المرور'), findsOneWidget);
      expect(find.text('أدخل بريدك الإلكتروني'), findsOneWidget);
      expect(find.byKey(const ValueKey('custom_badge_key')), findsOneWidget);
    });
  });
}
