import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/section_title.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('SectionTitle Widget Tests', () {
    testWidgets(
      'should render title without action text when onActionTap is null',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const SectionTitle(title: 'ملخص الطلب'),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('ملخص الطلب'), findsOneWidget);
        expect(find.text(AppStrings.edit), findsNothing);
      },
    );

    testWidgets(
      'should render default edit action text and trigger onActionTap when tapped',
      (tester) async {
        // Arrange
        var tapped = false;
        await tester.pumpWidget(
          createWidgetForTesting(
            child: SectionTitle(
              title: 'طريقة الدفع',
              onActionTap: () => tapped = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert text present
        expect(find.text('طريقة الدفع'), findsOneWidget);
        expect(find.text(AppStrings.edit), findsOneWidget);

        // Act
        await tester.tap(find.text(AppStrings.edit));
        await tester.pumpAndSettle();

        // Assert callback fired
        expect(tapped, isTrue);
      },
    );

    testWidgets('should render custom actionText when provided', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: SectionTitle(
            title: 'عنوان التوصيل',
            actionText: 'تعديل العنوان',
            onActionTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('عنوان التوصيل'), findsOneWidget);
      expect(find.text('تعديل العنوان'), findsOneWidget);
    });
  });
}
