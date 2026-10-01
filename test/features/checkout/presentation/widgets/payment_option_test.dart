import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/payment_option.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  const tFreePaymentOption = PaymentOptionEntity(
    title: 'الدفع بواسطة باي بال',
    type: PaymentMethodType.paypal,
    shippingCost: 0,
  );

  const tPaidPaymentOption = PaymentOptionEntity(
    title: 'الدفع عند الاستلام',
    type: PaymentMethodType.cash,
    shippingCost: 30,
  );

  void setWindowSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('PaymentOption Widget Tests', () {
    testWidgets(
      'should render title and free shipping text when shippingCost is zero',
      (tester) async {
        // Arrange
        setWindowSize(tester);

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: PaymentOption(
              paymentOptionEntity: tFreePaymentOption,
              isSelected: false,
              onTap: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('الدفع بواسطة باي بال'), findsOneWidget);
        expect(find.text(AppStrings.freeShipping), findsOneWidget);
      },
    );

    testWidgets(
      'should render formatted shipping cost when shippingCost is greater than zero',
      (tester) async {
        // Arrange
        setWindowSize(tester);

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: PaymentOption(
              paymentOptionEntity: tPaidPaymentOption,
              isSelected: true,
              onTap: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('الدفع عند الاستلام'), findsOneWidget);
        expect(find.text('30.0 ${AppStrings.pounds}'), findsOneWidget);
      },
    );

    testWidgets('should invoke onTap callback with entity when tapped', (
      tester,
    ) async {
      // Arrange
      setWindowSize(tester);
      PaymentOptionEntity? tappedEntity;
      await tester.pumpWidget(
        createWidgetForTesting(
          child: PaymentOption(
            paymentOptionEntity: tFreePaymentOption,
            isSelected: false,
            onTap: (entity) => tappedEntity = entity,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(PaymentOption));
      await tester.pumpAndSettle();

      // Assert
      expect(tappedEntity, equals(tFreePaymentOption));
    });

    testWidgets(
      'should show primary border and filled radio circle when isSelected is true',
      (tester) async {
        // Arrange
        setWindowSize(tester);

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: PaymentOption(
              paymentOptionEntity: tFreePaymentOption,
              isSelected: true,
              onTap: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert — AnimatedContainer has primary border
        final animatedContainer = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final outerDecoration = animatedContainer.decoration as BoxDecoration;
        expect(outerDecoration.border, isNotNull);

        // Assert — inner filled circle exists (child of radio Container)
        final containers = tester
            .widgetList<Container>(find.byType(Container))
            .toList();
        // The radio outer container has a child Container (filled circle) when selected
        final hasFilledCircle = containers.any((c) {
          final d = c.decoration;
          return d is BoxDecoration &&
              d.shape == BoxShape.circle &&
              d.color != null;
        });
        expect(hasFilledCircle, isTrue);
      },
    );

    testWidgets(
      'should show border-only radio circle and no filled circle when isSelected is false',
      (tester) async {
        // Arrange
        setWindowSize(tester);

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: PaymentOption(
              paymentOptionEntity: tFreePaymentOption,
              isSelected: false,
              onTap: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert — AnimatedContainer has border (not null)
        final animatedContainer = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final outerDecoration = animatedContainer.decoration as BoxDecoration;
        expect(outerDecoration.border, isNotNull);

        // Assert — no filled inner circle (child is null when not selected)
        final containers = tester
            .widgetList<Container>(find.byType(Container))
            .toList();
        // Only the outer radio circle exists; it has no color fill
        final filledCircles = containers.where((c) {
          final d = c.decoration;
          return d is BoxDecoration &&
              d.shape == BoxShape.circle &&
              d.color != null;
        });
        expect(filledCircles, isEmpty);
      },
    );
  });
}
