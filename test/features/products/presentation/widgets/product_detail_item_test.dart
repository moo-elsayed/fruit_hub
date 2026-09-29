import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/theming/colors_manager.dart';
import 'package:fruit_hub/features/products/domain/entities/product_details_entity.dart';
import 'package:fruit_hub/features/products/presentation/widgets/product_detail_item.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  const dummyDetail = ProductDetailsEntity(
    title: '100%',
    subtitle: 'طازج',
    trailingAsset: AppAssets.iconsCalory,
  );

  group('ProductDetailItem Widget Tests', () {
    testWidgets('should render title, subtitle, and svg icon', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const ProductDetailItem(productDetail: dummyDetail, index: 0),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('طازج'), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets(
      'should apply color based on index % 3 to title, svg, and container',
      (WidgetTester tester) async {
        final expectedColors = [
          LightColors().info, // index % 3 == 0
          LightColors().primary, // index % 3 == 1
          LightColors().secondary, // index % 3 == 2
        ];

        // Arrange & Act - Index 0, 1, 2
        for (int i = 0; i < 3; i++) {
          await tester.pumpWidget(
            createWidgetForTesting(
              child: ProductDetailItem(productDetail: dummyDetail, index: i),
            ),
          );
          await tester.pump();

          // Assert text color
          final titleText = tester.widget<Text>(find.text(dummyDetail.title));
          expect(titleText.style?.color, equals(expectedColors[i]));

          // Assert SVG color filter
          final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
          expect(
            svg.colorFilter,
            equals(ColorFilter.mode(expectedColors[i], BlendMode.srcIn)),
          );

          // Assert icon container background color
          final circleContainer = tester.widget<Container>(
            find.byWidgetPredicate(
              (w) =>
                  w is Container &&
                  w.decoration is BoxDecoration &&
                  (w.decoration as BoxDecoration).shape == BoxShape.circle,
            ),
          );
          final decoration = circleContainer.decoration as BoxDecoration;
          expect(
            decoration.color,
            equals(expectedColors[i].withValues(alpha: 0.1)),
          );
        }
      },
    );
  });
}
