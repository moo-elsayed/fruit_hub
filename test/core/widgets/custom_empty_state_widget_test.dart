import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/widgets/custom_empty_state_widget.dart';

import '../../helpers/test_widget_wrapper.dart';

void main() {
  group('CustomEmptyStateWidget Widget Tests', () {
    testWidgets('should render custom title and text when provided', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const CustomEmptyStateWidget(
            title: 'Cart is empty',
            text: 'Explore products and add items to your cart',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Cart is empty'), findsOneWidget);
      expect(
        find.text('Explore products and add items to your cart'),
        findsOneWidget,
      );
    });

    testWidgets('should render customIcon when provided', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const CustomEmptyStateWidget(
            customIcon: Icon(
              Icons.shopping_bag_outlined,
              key: Key('custom_cart_icon'),
            ),
            title: 'Empty State',
            text: 'Nothing here',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const Key('custom_cart_icon')), findsOneWidget);
      expect(find.text('Empty State'), findsOneWidget);
    });

    testWidgets(
      'should fallback to default search image when imagePath and svgPath are null',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(child: const CustomEmptyStateWidget()),
        );
        await tester.pumpAndSettle();

        // Assert
        final imageWidget = tester.widget<Image>(find.byType(Image));
        expect(
          (imageWidget.image as AssetImage).assetName,
          equals(AppAssets.imagesSearchImage),
        );
        expect(find.byType(SvgPicture), findsNothing);
      },
    );

    testWidgets('should render custom imagePath when provided', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const CustomEmptyStateWidget(
            imagePath: AppAssets.imagesFruitsImage,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect(
        (imageWidget.image as AssetImage).assetName,
        equals(AppAssets.imagesFruitsImage),
      );
      expect(find.byType(SvgPicture), findsNothing);
    });

    testWidgets('should render SvgPicture when svgPath is provided', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const CustomEmptyStateWidget(
            svgPath: AppAssets.iconsIconCancel,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });
}
