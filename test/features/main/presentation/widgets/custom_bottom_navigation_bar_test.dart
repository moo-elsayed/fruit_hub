import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/features/main/presentation/items/nav_bar_item.dart';
import 'package:fruit_hub/features/main/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:fruit_hub/features/main/presentation/widgets/custom_bottom_navigation_bar_item_widget.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  const tNavItems = [
    NavBarItem(
      icon: AppAssets.iconsHomeOutline,
      activeIcon: AppAssets.iconsHomeFilled,
      label: 'Home',
    ),
    NavBarItem(
      icon: AppAssets.iconsHeart,
      activeIcon: AppAssets.iconsHeart,
      label: 'Favorites',
    ),
    NavBarItem(
      icon: AppAssets.iconsShoppingCartOutline,
      activeIcon: AppAssets.iconsShoppingCartFilled,
      label: 'Cart',
    ),
    NavBarItem(
      icon: AppAssets.iconsProfileOutline,
      activeIcon: AppAssets.iconsProfileFilled,
      label: 'Account',
    ),
  ];

  group('CustomBottomNavigationBar Widget Tests', () {
    testWidgets('should render all navigation bar items', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomBottomNavigationBar(
            currentIndex: 0,
            items: tNavItems,
            onTabSelected: (_) {},
          ),
        ),
      );

      // Assert
      expect(
        find.byType(CustomBottomNavigationItemWidget),
        findsNWidgets(tNavItems.length),
      );
    });

    testWidgets('should mark only the item at currentIndex as selected', (
      tester,
    ) async {
      // Arrange & Act - select index 1 ('Favorites')
      await tester.pumpWidget(
        createWidgetForTesting(
          child: CustomBottomNavigationBar(
            currentIndex: 1,
            items: tNavItems,
            onTabSelected: (_) {},
          ),
        ),
      );

      // Assert - only 'Favorites' label should be visible
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
      expect(find.text('Cart'), findsNothing);
      expect(find.text('Account'), findsNothing);
    });

    testWidgets(
      'should invoke onTabSelected with correct index when an item is tapped',
      (tester) async {
        // Arrange
        int? selectedIndex;
        await tester.pumpWidget(
          createWidgetForTesting(
            child: CustomBottomNavigationBar(
              currentIndex: 0,
              items: tNavItems,
              onTabSelected: (index) => selectedIndex = index,
            ),
          ),
        );

        // Act - Tap on the 3rd item (Cart, index 2)
        final cartItem = find.byType(CustomBottomNavigationItemWidget).at(2);
        await tester.tap(cartItem);
        await tester.pump();

        // Assert
        expect(selectedIndex, 2);
      },
    );
  });
}
