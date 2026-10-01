import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/payment_body.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/payment_option.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockCheckoutCubit extends MockCubit<CheckoutState>
    implements CheckoutCubit {}

class FakePaymentOptionEntity extends Fake implements PaymentOptionEntity {}

void main() {
  late MockCheckoutCubit mockCheckoutCubit;

  const tInitialOption = PaymentOptionEntity(
    title: 'باي بال',
    type: PaymentMethodType.paypal,
    shippingCost: 0,
  );

  const tShippingConfig = ShippingConfigEntity(
    shippingCost: 30,
    freeShippingThreshold: 200,
  );

  setUpAll(() {
    registerFallbackValue(FakePaymentOptionEntity());
  });

  setUp(() {
    mockCheckoutCubit = MockCheckoutCubit();

    when(() => mockCheckoutCubit.state).thenReturn(CheckoutInitial());
    when(() => mockCheckoutCubit.subtotal).thenReturn(100.0);
    when(() => mockCheckoutCubit.shippingConfig).thenReturn(tShippingConfig);
    when(() => mockCheckoutCubit.paymentOption).thenReturn(tInitialOption);
    when(() => mockCheckoutCubit.setPaymentOption(any())).thenReturn(null);
  });

  void setWindowSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildTestWidget() => createWidgetForTesting(
    child: BlocProvider<CheckoutCubit>.value(
      value: mockCheckoutCubit,
      child: const PaymentBody(),
    ),
  );

  group('PaymentBody Widget Tests', () {
    testWidgets(
      'should render header and 3 payment options, and set initial option on Cubit',
      (tester) async {
        // Arrange
        setWindowSize(tester);

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text(AppStrings.chooseThePaymentMethodThatSuitsYouBest),
          findsOneWidget,
        );
        expect(find.byType(PaymentOption), findsNWidgets(3));
        verify(
          () => mockCheckoutCubit.setPaymentOption(
            any(
              that: isA<PaymentOptionEntity>().having(
                (o) => o.type,
                'type',
                PaymentMethodType.paypal,
              ),
            ),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'should update selected option and call cubit.setPaymentOption when tapping a different option',
      (tester) async {
        // Arrange
        setWindowSize(tester);
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act - Tap on the 3rd payment option (cash on delivery)
        await tester.tap(find.byType(PaymentOption).at(2));
        await tester.pumpAndSettle();

        // Assert
        verify(
          () => mockCheckoutCubit.setPaymentOption(
            any(
              that: isA<PaymentOptionEntity>().having(
                (o) => o.type,
                'type',
                PaymentMethodType.cash,
              ),
            ),
          ),
        ).called(1);
      },
    );
  });
}
