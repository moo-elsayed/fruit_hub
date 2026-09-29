import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/colors_manager.dart';
import 'package:fruit_hub/core/widgets/order_timeline_preview.dart';

import '../../helpers/test_widget_wrapper.dart';

void main() {
  final lightColors = LightColors();
  final darkColors = DarkColors();

  List<BoxDecoration> getStepCircleDecorations(WidgetTester tester) => tester
      .widgetList<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              (w.decoration as BoxDecoration?)?.shape == BoxShape.circle,
        ),
      )
      .map((w) => w.decoration as BoxDecoration)
      .toList();

  List<Icon> getStepIcons(WidgetTester tester) =>
      tester.widgetList<Icon>(find.byType(Icon)).toList();

  List<Container> getConnectorLines(WidgetTester tester) => tester
      .widgetList<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.margin != null &&
              w.decoration == null &&
              w.color != null,
        ),
      )
      .toList();

  group('OrderTimelinePreview Widget Tests', () {
    testWidgets(
      'should render all 4 step titles and their corresponding icons',
      (tester) async {
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const OrderTimelinePreview(currentStep: 1),
          ),
        );

        // Verify titles
        expect(find.text(AppStrings.orderPlaced), findsOneWidget);
        expect(find.text(AppStrings.orderPreparing), findsOneWidget);
        expect(find.text(AppStrings.orderOnTheWay), findsOneWidget);
        expect(find.text(AppStrings.orderDelivered), findsOneWidget);

        // Verify icons
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
        expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
        expect(find.byIcon(Icons.delivery_dining_outlined), findsOneWidget);
        expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'should style completed, active, and unreached steps correctly when currentStep is 1',
      (tester) async {
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const OrderTimelinePreview(currentStep: 1),
          ),
        );

        final circles = getStepCircleDecorations(tester);
        final icons = getStepIcons(tester);
        final lines = getConnectorLines(tester);

        expect(circles.length, equals(4));
        expect(icons.length, equals(4));
        expect(lines.length, equals(3));

        // Step 0: Completed (orderPlaced)
        expect(circles[0].color, equals(lightColors.primary));
        expect(circles[0].border, isNull);
        expect(icons[0].color, equals(AppPalette.white));

        // Step 1: Active / Current (orderPreparing)
        expect(
          circles[1].color,
          equals(lightColors.primary.withValues(alpha: 0.15)),
        );
        expect(circles[1].border, isNotNull);
        expect(circles[1].border!.top.color, equals(lightColors.primary));
        expect(icons[1].color, equals(lightColors.primary));

        // Step 2 & 3: Unreached (orderOnTheWay, orderDelivered)
        expect(circles[2].color, equals(lightColors.background));
        expect(circles[2].border!.top.color, equals(lightColors.border));
        expect(icons[2].color, equals(lightColors.subText));

        expect(circles[3].color, equals(lightColors.background));
        expect(circles[3].border!.top.color, equals(lightColors.border));
        expect(icons[3].color, equals(lightColors.subText));

        // Connector Lines
        // Line 0 (between 0 and 1): completed -> primary color
        expect(lines[0].color, equals(lightColors.primary));
        // Line 1 & 2: unreached -> border color
        expect(lines[1].color, equals(lightColors.border));
        expect(lines[2].color, equals(lightColors.border));

        // Text font weights
        final preparingText = tester.widget<Text>(
          find.text(AppStrings.orderPreparing),
        );
        expect(preparingText.style?.fontWeight, equals(FontWeight.bold));

        final onTheWayText = tester.widget<Text>(
          find.text(AppStrings.orderOnTheWay),
        );
        expect(onTheWayText.style?.fontWeight, equals(FontWeight.normal));
        expect(onTheWayText.style?.color, equals(lightColors.subText));
      },
    );

    testWidgets(
      'should style all steps and lines as completed when currentStep is 3 (delivered)',
      (tester) async {
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const OrderTimelinePreview(currentStep: 3),
          ),
        );

        final circles = getStepCircleDecorations(tester);
        final icons = getStepIcons(tester);
        final lines = getConnectorLines(tester);

        // All 4 circles should be completed with primary background and white icons
        for (var i = 0; i < 4; i++) {
          expect(circles[i].color, equals(lightColors.primary));
          expect(circles[i].border, isNull);
          expect(icons[i].color, equals(AppPalette.white));
        }

        // All 3 connector lines should have primary color
        for (var i = 0; i < 3; i++) {
          expect(lines[i].color, equals(lightColors.primary));
        }

        // All text labels should use mainText color
        final deliveredText = tester.widget<Text>(
          find.text(AppStrings.orderDelivered),
        );
        expect(deliveredText.style?.color, equals(lightColors.mainText));
      },
    );

    testWidgets(
      'should style step 0 as active and subsequent lines as unreached when currentStep is 0',
      (tester) async {
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const OrderTimelinePreview(currentStep: 0),
          ),
        );

        final circles = getStepCircleDecorations(tester);
        final lines = getConnectorLines(tester);

        // Step 0 is active
        expect(
          circles[0].color,
          equals(lightColors.primary.withValues(alpha: 0.15)),
        );
        expect(circles[0].border, isNotNull);

        // All lines unreached
        for (var i = 0; i < 3; i++) {
          expect(lines[i].color, equals(lightColors.border));
        }
      },
    );

    testWidgets('should safely clamp negative currentStep to 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const OrderTimelinePreview(currentStep: -10),
        ),
      );

      final circles = getStepCircleDecorations(tester);
      expect(
        circles[0].color,
        equals(lightColors.primary.withValues(alpha: 0.15)),
      );
    });

    testWidgets('should safely clamp excessive currentStep to 3', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const OrderTimelinePreview(currentStep: 999),
        ),
      );

      final circles = getStepCircleDecorations(tester);
      for (var i = 0; i < 4; i++) {
        expect(circles[i].color, equals(lightColors.primary));
      }
    });

    testWidgets(
      'should render background color according to light and dark theme mode',
      (tester) async {
        // Light Mode
        await tester.pumpWidget(
          createWidgetForTesting(
            themeMode: ThemeMode.light,
            child: const OrderTimelinePreview(currentStep: 1),
          ),
        );

        var container = tester.widget<Container>(find.byType(Container).first);
        var decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(AppPalette.bgLightSecondary));

        // Dark Mode
        await tester.pumpWidget(
          createWidgetForTesting(
            themeMode: ThemeMode.dark,
            child: const OrderTimelinePreview(currentStep: 1),
          ),
        );

        container = tester.widget<Container>(find.byType(Container).first);
        decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(darkColors.surface));
      },
    );
  });
}
