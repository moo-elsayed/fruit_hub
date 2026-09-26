import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/features/onboarding/presentation/widgets/onboarding_item_title.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('OnboardingItemTitle Widget Tests', () {
    testWidgets(
      'should render standard Text widget when title does not end with FruitHUB',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const OnboardingItemTitle(title: 'ابحث وتسوق'),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(Text), findsOneWidget);
        expect(find.text('ابحث وتسوق'), findsOneWidget);
      },
    );

    testWidgets(
      'should render RichText with colored Fruit and HUB spans when title ends with FruitHUB',
      (WidgetTester tester) async {
        // Arrange
        late BuildContext capturedContext;
        await tester.pumpWidget(
          createWidgetForTesting(
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return const OnboardingItemTitle(
                  title: 'مرحبًا بك في FruitHUB',
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final richTextFinder = find.byType(RichText);
        expect(richTextFinder, findsOneWidget);

        final richText = tester.widget<RichText>(richTextFinder);
        final rootSpan = richText.text as TextSpan;
        expect(rootSpan.children?.length, equals(3));

        final prefixSpan = rootSpan.children![0] as TextSpan;
        final fruitSpan = rootSpan.children![1] as TextSpan;
        final hubSpan = rootSpan.children![2] as TextSpan;

        expect(prefixSpan.text, equals('مرحبًا بك في '));
        expect(fruitSpan.text, equals('Fruit'));
        expect(fruitSpan.style?.color, equals(capturedContext.colors.primary));
        expect(hubSpan.text, equals('HUB'));
        expect(hubSpan.style?.color, equals(capturedContext.colors.secondary));
      },
    );
  });
}
