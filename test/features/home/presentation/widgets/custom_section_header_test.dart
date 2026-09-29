import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/home/presentation/widgets/custom_section_header.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('CustomSectionHeader Widget Tests', () {
    testWidgets('should render section name and more text correctly', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomSectionHeader(
            sectionName: AppStrings.bestSeller,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(AppStrings.bestSeller), findsOneWidget);
      expect(find.text(AppStrings.more), findsOneWidget);
    });

    testWidgets('should trigger onTap callback when more text is tapped', (
      tester,
    ) async {
      // Arrange
      var wasTapped = false;
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomSectionHeader(
            sectionName: 'الأكثر مبيعًا',
            onTap: () => wasTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text(AppStrings.more));
      await tester.pumpAndSettle();

      // Assert
      expect(wasTapped, isTrue);
    });
  });
}
