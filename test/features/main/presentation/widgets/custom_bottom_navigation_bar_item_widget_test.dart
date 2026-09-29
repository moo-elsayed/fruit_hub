import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/features/main/presentation/items/custom_bottom_navigation_item_params.dart';
import 'package:fruit_hub/features/main/presentation/widgets/custom_bottom_navigation_bar_item_widget.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('CustomBottomNavigationItemWidget Widget Tests', () {
    testWidgets(
      'should render label and active styling when isSelected is true',
      (tester) async {
        // Arrange
        final params = CustomBottomNavigationItemParams(
          isSelected: true,
          icon: AppAssets.iconsHomeOutline,
          activeIcon: AppAssets.iconsHomeFilled,
          label: 'Home',
          onTap: () {},
        );

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: CustomBottomNavigationItemWidget(params: params),
          ),
        );

        // Assert
        expect(find.text('Home'), findsOneWidget);
      },
    );

    testWidgets('should not render label when isSelected is false', (
      tester,
    ) async {
      // Arrange
      final params = CustomBottomNavigationItemParams(
        isSelected: false,
        icon: AppAssets.iconsHomeOutline,
        activeIcon: AppAssets.iconsHomeFilled,
        label: 'Home',
        onTap: () {},
      );

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomBottomNavigationItemWidget(params: params),
        ),
      );

      // Assert
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('should trigger onTap callback when item is tapped', (
      tester,
    ) async {
      // Arrange
      bool wasTapped = false;
      final params = CustomBottomNavigationItemParams(
        isSelected: false,
        icon: AppAssets.iconsHomeOutline,
        label: 'Home',
        onTap: () => wasTapped = true,
      );

      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomBottomNavigationItemWidget(params: params),
        ),
      );

      // Act
      await tester.tap(find.byType(CustomBottomNavigationItemWidget));
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets(
      'should animate and display label when isSelected changes from false to true',
      (tester) async {
        // Arrange - initial unselected
        final unselectedParams = CustomBottomNavigationItemParams(
          isSelected: false,
          icon: AppAssets.iconsHomeOutline,
          activeIcon: AppAssets.iconsHomeFilled,
          label: 'Home',
          onTap: () {},
        );

        await tester.pumpWidget(
          createWidgetForTesting(
            child: CustomBottomNavigationItemWidget(params: unselectedParams),
          ),
        );
        expect(find.text('Home'), findsNothing);

        // Act - update to selected
        final selectedParams = CustomBottomNavigationItemParams(
          isSelected: true,
          icon: AppAssets.iconsHomeOutline,
          activeIcon: AppAssets.iconsHomeFilled,
          label: 'Home',
          onTap: () {},
        );

        await tester.pumpWidget(
          createWidgetForTesting(
            child: CustomBottomNavigationItemWidget(params: selectedParams),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Home'), findsOneWidget);
      },
    );
  });
}
