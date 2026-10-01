import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/payment_review_card.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('PaymentReviewCard Widget Tests', () {
    testWidgets('should render title and paypal image when type is paypal', (
      tester,
    ) async {
      // Arrange
      const option = PaymentOptionEntity(
        title: 'باي بال',
        type: PaymentMethodType.paypal,
      );

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const PaymentReviewCard(paymentOption: option),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('باي بال'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should render title and card SVG when type is card', (
      tester,
    ) async {
      // Arrange
      const option = PaymentOptionEntity(
        title: 'بطاقة ائتمان',
        type: PaymentMethodType.card,
      );

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const PaymentReviewCard(paymentOption: option),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('بطاقة ائتمان'), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('should render title and cash image when type is cash', (
      tester,
    ) async {
      // Arrange
      const option = PaymentOptionEntity(
        title: 'الدفع عند الاستلام',
        type: PaymentMethodType.cash,
      );

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: const PaymentReviewCard(paymentOption: option),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('الدفع عند الاستلام'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
