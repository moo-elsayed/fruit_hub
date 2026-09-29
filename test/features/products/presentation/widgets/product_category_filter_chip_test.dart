import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/product_category_filter.dart';
import 'package:fruit_hub/features/products/presentation/widgets/product_category_filter_chip.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('ProductCategoryFilterChip Widget Tests', () {
    testWidgets('should render category label and trigger onTap when tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      var tapped = false;
      await tester.pumpWidget(
        createWidgetForTesting(
          child: ProductCategoryFilterChip(
            category: ProductCategoryFilter.organic,
            isSelected: false,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text(ProductCategoryFilter.organic.label), findsOneWidget);

      // Act
      await tester.tap(find.byType(ProductCategoryFilterChip));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should render properly when isSelected is true and false', (
      WidgetTester tester,
    ) async {
      // Arrange & Act - Selected
      await tester.pumpWidget(
        createWidgetForTesting(
          child: ProductCategoryFilterChip(
            category: ProductCategoryFilter.all,
            isSelected: true,
            onTap: () {},
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text(ProductCategoryFilter.all.label), findsOneWidget);

      // Arrange & Act - Unselected
      await tester.pumpWidget(
        createWidgetForTesting(
          child: ProductCategoryFilterChip(
            category: ProductCategoryFilter.featured,
            isSelected: false,
            onTap: () {},
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text(ProductCategoryFilter.featured.label), findsOneWidget);
    });
  });
}
