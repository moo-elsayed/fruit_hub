import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/address_review_card.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_review_body.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_summary.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/payment_review_card.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/section_title.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockCheckoutCubit extends MockCubit<CheckoutState>
    implements CheckoutCubit {}

void main() {
  late MockCheckoutCubit mockCheckoutCubit;

  const tAddress = AddressEntity(
    name: 'سارة أحمد',
    phone: '01000000000',
    city: 'القاهرة',
    streetName: 'شارع النصر',
  );

  const tPaymentOption = PaymentOptionEntity(
    title: 'الدفع عند الاستلام',
    type: PaymentMethodType.cash,
    shippingCost: 20,
  );

  setUp(() {
    mockCheckoutCubit = MockCheckoutCubit();

    when(() => mockCheckoutCubit.state).thenReturn(CheckoutInitial());
    when(() => mockCheckoutCubit.address).thenReturn(tAddress);
    when(() => mockCheckoutCubit.paymentOption).thenReturn(tPaymentOption);
    when(() => mockCheckoutCubit.subtotal).thenReturn(150.0);
  });

  void setWindowSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildTestWidget({ValueChanged<int>? onEditStep}) =>
      createWidgetForTesting(
        child: BlocProvider<CheckoutCubit>.value(
          value: mockCheckoutCubit,
          child: OrderReviewBody(onEditStep: onEditStep),
        ),
      );

  group('OrderReviewBody Widget Tests', () {
    testWidgets(
      'should render OrderSummary, PaymentReviewCard, and AddressReviewCard with cubit data',
      (tester) async {
        // Arrange
        setWindowSize(tester);

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(OrderSummary), findsOneWidget);
        expect(find.byType(PaymentReviewCard), findsOneWidget);
        expect(find.byType(AddressReviewCard), findsOneWidget);
        expect(find.byType(SectionTitle), findsNWidgets(3));
        expect(find.text('سارة أحمد'), findsOneWidget);
        expect(find.text('الدفع عند الاستلام'), findsOneWidget);
      },
    );

    testWidgets(
      'should invoke onEditStep with index 1 when payment method edit is tapped',
      (tester) async {
        // Arrange
        setWindowSize(tester);
        int? editedIndex;
        await tester.pumpWidget(
          buildTestWidget(onEditStep: (index) => editedIndex = index),
        );
        await tester.pumpAndSettle();

        // Act - Tap first edit button (Payment Method is 1st edit button since OrderSummary has no onActionTap)
        final editFinders = find.text(AppStrings.edit);
        expect(editFinders, findsNWidgets(2));
        await tester.tap(editFinders.at(0));
        await tester.pumpAndSettle();

        // Assert
        expect(editedIndex, equals(1));
      },
    );

    testWidgets(
      'should invoke onEditStep with index 0 when address edit is tapped',
      (tester) async {
        // Arrange
        setWindowSize(tester);
        int? editedIndex;
        await tester.pumpWidget(
          buildTestWidget(onEditStep: (index) => editedIndex = index),
        );
        await tester.pumpAndSettle();

        // Act - Tap second edit button (Delivery Address edit button)
        final editFinders = find.text(AppStrings.edit);
        expect(editFinders, findsNWidgets(2));
        await tester.tap(editFinders.at(1));
        await tester.pumpAndSettle();

        // Assert
        expect(editedIndex, equals(0));
      },
    );
  });
}
