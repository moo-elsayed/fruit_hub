import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/args/address_args.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/address_body.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/checkout_page_view.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_review_body.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/payment_body.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockCheckoutCubit extends MockCubit<CheckoutState>
    implements CheckoutCubit {}

class MockUserInfoCubit extends MockCubit<UserInfoState>
    implements UserInfoCubit {}

class FakePaymentOptionEntity extends Fake implements PaymentOptionEntity {}

void main() {
  late MockCheckoutCubit mockCheckoutCubit;
  late MockUserInfoCubit mockUserInfoCubit;
  late PageController pageController;
  late AddressArgs addressArgs;

  const tUser = UserEntity(
    uid: 'u_1',
    name: 'محمود السيد',
    email: 'test@fruithub.com',
  );

  const tAddress = AddressEntity(
    name: 'محمود السيد',
    phone: '01012345678',
    city: 'القاهرة',
    streetName: 'شارع التحرير',
  );

  const tPaymentOption = PaymentOptionEntity(
    title: 'الدفع عند الاستلام',
    type: PaymentMethodType.cash,
    shippingCost: 30,
  );

  setUpAll(() {
    registerFallbackValue(FakePaymentOptionEntity());
  });

  setUp(() {
    mockCheckoutCubit = MockCheckoutCubit();
    mockUserInfoCubit = MockUserInfoCubit();
    pageController = PageController();
    addressArgs = AddressArgs();

    when(() => mockCheckoutCubit.state).thenReturn(CheckoutInitial());
    when(() => mockCheckoutCubit.address).thenReturn(tAddress);
    when(() => mockCheckoutCubit.paymentOption).thenReturn(tPaymentOption);
    when(() => mockCheckoutCubit.subtotal).thenReturn(200.0);
    when(() => mockCheckoutCubit.shippingConfig)
        .thenReturn(const ShippingConfigEntity(shippingCost: 30));
    when(() => mockCheckoutCubit.saveAddress).thenReturn(true);
    when(() => mockCheckoutCubit.setPaymentOption(any())).thenReturn(null);

    when(() => mockUserInfoCubit.state).thenReturn(UserInfoInitial());
    when(() => mockUserInfoCubit.currentUser).thenReturn(tUser);
  });

  tearDown(() {
    pageController.dispose();
    addressArgs.dispose();
  });

  void setWindowSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildTestWidget({ValueChanged<int>? onPageChanged}) =>
      createWidgetForTesting(
        child: MultiBlocProvider(
          providers: [
            BlocProvider<CheckoutCubit>.value(value: mockCheckoutCubit),
            BlocProvider<UserInfoCubit>.value(value: mockUserInfoCubit),
          ],
          child: Column(
            children: [
              CheckoutPageView(
                pageController: pageController,
                addressArgs: addressArgs,
                onPageChanged: onPageChanged,
              ),
            ],
          ),
        ),
      );

  group('CheckoutPageView Widget Tests', () {
    testWidgets('should render AddressBody on page 0 by default', (
      tester,
    ) async {
      // Arrange
      setWindowSize(tester);

      // Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AddressBody), findsOneWidget);
      expect(find.byType(PaymentBody), findsNothing);
      expect(find.byType(OrderReviewBody), findsNothing);
    });

    testWidgets(
      'should render PaymentBody when jumping to page 1 and fire onPageChanged',
      (tester) async {
        // Arrange
        setWindowSize(tester);
        int? currentPage;
        await tester.pumpWidget(
          buildTestWidget(onPageChanged: (page) => currentPage = page),
        );
        await tester.pumpAndSettle();

        // Act
        pageController.jumpToPage(1);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(PaymentBody), findsOneWidget);
        expect(find.byType(AddressBody), findsNothing);
        expect(currentPage, equals(1));
      },
    );

    testWidgets('should render OrderReviewBody when jumping to page 2', (
      tester,
    ) async {
      // Arrange
      setWindowSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Act
      pageController.jumpToPage(2);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(OrderReviewBody), findsOneWidget);
      expect(find.byType(PaymentBody), findsNothing);
    });
  });
}
