import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_arrow_back.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/views/checkout_view.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/checkout_button_bloc_consumer.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/checkout_page_view.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/checkout_steps.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockCheckoutCubit extends MockCubit<CheckoutState>
    implements CheckoutCubit {}

class MockCartCubit extends MockCubit<CartState> implements CartCubit {}

class MockUserInfoCubit extends MockCubit<UserInfoState>
    implements UserInfoCubit {}

class TestNavigatorObserver extends NavigatorObserver {
  bool didPopRoute = false;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    didPopRoute = true;
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(const PaymentOptionEntity());
  });

  late MockCheckoutCubit mockCheckoutCubit;
  late MockCartCubit mockCartCubit;
  late MockUserInfoCubit mockUserInfoCubit;
  late TestNavigatorObserver navObserver;

  const tUser = UserEntity(
    uid: 'user_123',
    name: 'أحمد علي',
    email: 'ahmed@example.com',
    phone: '01012345678',
  );

  const tCartItems = [
    CartItemEntity(
      fruitEntity: FruitEntity(name: 'تفاح', price: 25),
      quantity: 2,
    ),
  ];

  void setWindowSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  setUp(() {
    AppToast.isEnabled = false;
    mockCheckoutCubit = MockCheckoutCubit();
    mockCartCubit = MockCartCubit();
    mockUserInfoCubit = MockUserInfoCubit();
    navObserver = TestNavigatorObserver();

    when(() => mockCheckoutCubit.state).thenReturn(CheckoutInitial());
    when(() => mockCheckoutCubit.close()).thenAnswer((_) async {});
    when(() => mockCheckoutCubit.setProducts(any())).thenReturn(null);
    when(() => mockCheckoutCubit.getAddressFromLocalStorage()).thenReturn(null);
    when(() => mockCheckoutCubit.fetchShippingConfig())
        .thenAnswer((_) async {});
    when(() => mockCheckoutCubit.saveAddress).thenReturn(true);
    when(() => mockCheckoutCubit.address).thenReturn(null);
    when(() => mockCheckoutCubit.shippingConfig)
        .thenReturn(const ShippingConfigEntity());
    when(() => mockCheckoutCubit.subtotal).thenReturn(50.0);
    when(() => mockCheckoutCubit.paymentOption)
        .thenReturn(const PaymentOptionEntity(type: PaymentMethodType.cash));
    when(() => mockCheckoutCubit.setPaymentOption(any())).thenReturn(null);

    when(() => mockUserInfoCubit.currentUser).thenReturn(tUser);
    when(() => mockUserInfoCubit.state).thenReturn(UserInfoInitial());

    if (getIt.isRegistered<CheckoutCubit>()) {
      getIt.unregister<CheckoutCubit>();
    }
    getIt.registerFactory<CheckoutCubit>(() => mockCheckoutCubit);
  });

  tearDown(() {
    AppToast.isEnabled = true;
    toastification.dismissAll();
    getIt.reset();
  });

  Widget buildTestWidget() => createWidgetForTesting(
    navigatorObserver: navObserver,
    child: MultiBlocProvider(
      providers: [
        BlocProvider<CartCubit>.value(value: mockCartCubit),
        BlocProvider<UserInfoCubit>.value(value: mockUserInfoCubit),
      ],
      child: const CheckoutView(cartItems: tCartItems),
    ),
  );

  group('CheckoutView Widget Tests', () {
    testWidgets(
      'should initialize CheckoutCubit with products, stored address, and shipping config on init',
      (tester) async {
        // Arrange
        setWindowSize(tester);

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockCheckoutCubit.setProducts(tCartItems)).called(1);
        verify(() => mockCheckoutCubit.getAddressFromLocalStorage()).called(1);
        verify(() => mockCheckoutCubit.fetchShippingConfig()).called(1);
      },
    );

    testWidgets(
      'should render CustomAppBar, CheckoutSteps, CheckoutPageView, and CheckoutButtonBlocConsumer',
      (tester) async {
        // Arrange
        setWindowSize(tester);

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CustomAppBar), findsOneWidget);
        expect(find.text(AppStrings.address), findsWidgets);
        expect(find.byType(CheckoutSteps), findsOneWidget);
        expect(find.byType(CheckoutPageView), findsOneWidget);
        expect(find.byType(CheckoutButtonBlocConsumer), findsOneWidget);
      },
    );

    testWidgets('should pop screen when back arrow is tapped on step 0', (
      tester,
    ) async {
      // Arrange
      setWindowSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Act - Tap CustomAppBar back arrow
      final backButtonFinder = find.descendant(
        of: find.byType(CustomAppBar),
        matching: find.byType(CustomArrowBack),
      );
      await tester.tap(backButtonFinder.first);
      await tester.pumpAndSettle();

      // Assert
      expect(navObserver.didPopRoute, isTrue);
    });
  });
}
