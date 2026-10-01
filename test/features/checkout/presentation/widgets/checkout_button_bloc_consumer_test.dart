import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/args/address_args.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/checkout_button_bloc_consumer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockCheckoutCubit extends MockCubit<CheckoutState>
    implements CheckoutCubit {}

class MockCartCubit extends MockCubit<CartState> implements CartCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(const AddressEntity());
  });

  late MockCheckoutCubit mockCheckoutCubit;
  late MockCartCubit mockCartCubit;
  late StreamController<CheckoutState> checkoutStateController;
  late AddressArgs addressArgs;

  setUp(() {
    AppToast.isEnabled = true;
    mockCheckoutCubit = MockCheckoutCubit();
    mockCartCubit = MockCartCubit();
    checkoutStateController = StreamController<CheckoutState>.broadcast();
    addressArgs = AddressArgs();

    whenListen(
      mockCheckoutCubit,
      checkoutStateController.stream,
      initialState: CheckoutInitial(),
    );

    when(() => mockCheckoutCubit.paymentOption)
        .thenReturn(const PaymentOptionEntity(type: PaymentMethodType.cash));
    when(() => mockCheckoutCubit.orderEntity)
        .thenReturn(const OrderEntity(docId: 'ord_123', orderId: 123));

    when(() => mockCheckoutCubit.close()).thenAnswer((_) async {});
    when(() => mockCartCubit.close()).thenAnswer((_) async {});
    when(() => mockCheckoutCubit.addOrder()).thenAnswer((_) async {});
    when(() => mockCheckoutCubit.makePayment()).thenAnswer((_) async {});
    when(() => mockCartCubit.clearCart()).thenAnswer((_) async {});
  });

  tearDown(() async {
    toastification.dismissAll();
    addressArgs.dispose();
    await checkoutStateController.close();
  });

  Widget buildTestWidget({
    required int currentIndex,
    required VoidCallback onNext,
    NavigatorObserver? navigatorObserver,
  }) => createWidgetForTesting(
    withToastification: true,
    navigatorObserver: navigatorObserver,
    routes: {
      Routes.orderSuccessView: (context) =>
          const Scaffold(body: Text('Order Success Screen')),
    },
    child: MultiBlocProvider(
      providers: [
        BlocProvider<CheckoutCubit>.value(value: mockCheckoutCubit),
        BlocProvider<CartCubit>.value(value: mockCartCubit),
      ],
      child: Form(
        key: addressArgs.formKey,
        child: CheckoutButtonBlocConsumer(
          onNext: onNext,
          currentIndex: currentIndex,
          addressArgs: addressArgs,
        ),
      ),
    ),
  );

  group('CheckoutButtonBlocConsumer Widget Tests', () {
    group('Button Labels and Loading State', () {
      testWidgets('should show next button label when currentIndex is 0 or 1', (
        tester,
      ) async {
        // Arrange & Act - Step 0
        await tester.pumpWidget(
          buildTestWidget(currentIndex: 0, onNext: () {}),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(AppStrings.next), findsOneWidget);

        // Arrange & Act - Step 1
        await tester.pumpWidget(
          buildTestWidget(currentIndex: 1, onNext: () {}),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(AppStrings.next), findsOneWidget);
      });

      testWidgets(
        'should show confirmOrder button label when currentIndex is 2',
        (tester) async {
          // Arrange & Act
          await tester.pumpWidget(
            buildTestWidget(currentIndex: 2, onNext: () {}),
          );
          await tester.pumpAndSettle();

          // Assert
          expect(find.text(AppStrings.confirmOrder), findsOneWidget);
        },
      );

      testWidgets(
        'should show loading indicator when state is AddOrderLoading',
        (tester) async {
          // Arrange
          when(() => mockCheckoutCubit.state).thenReturn(AddOrderLoading());

          // Act
          await tester.pumpWidget(
            buildTestWidget(currentIndex: 2, onNext: () {}),
          );

          // Assert
          expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
        },
      );
    });

    group('Button Interactions per Step', () {
      testWidgets(
        'should show warning toast when form is valid but location is not selected on step 0',
        (tester) async {
          // Arrange
          addressArgs.nameController.text = 'Ahmed Mohamed';
          addressArgs.emailController.text = 'ahmed@example.com';
          addressArgs.phoneController.text = '01012345678';
          addressArgs.cityController.text = 'Cairo';
          addressArgs.streetNameController.text = 'Tahrir';
          addressArgs.buildingController.text = '12';
          addressArgs.floorController.text = '3';
          addressArgs.apartmentController.text = '4';
          // location coordinates not set

          bool nextCalled = false;
          await tester.pumpWidget(
            buildTestWidget(currentIndex: 0, onNext: () => nextCalled = true),
          );
          await tester.pumpAndSettle();

          // Act
          await tester.tap(find.text(AppStrings.next));
          await tester.pump();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 700));

          // Assert
          expect(nextCalled, isFalse);
          expect(
            find.text(
              AppStrings.pleaseSelectLocationOnMap,
              skipOffstage: false,
            ),
            findsOneWidget,
          );

          toastification.dismissAll();
          await tester.pump(const Duration(seconds: 4));
        },
      );

      testWidgets(
        'should call onNext and cubit.setAddress when step 0 is valid and has location',
        (tester) async {
          // Arrange
          addressArgs.nameController.text = 'Ahmed Mohamed';
          addressArgs.emailController.text = 'ahmed@example.com';
          addressArgs.phoneController.text = '01012345678';
          addressArgs.cityController.text = 'Cairo';
          addressArgs.streetNameController.text = 'Tahrir';
          addressArgs.buildingController.text = '12';
          addressArgs.floorController.text = '3';
          addressArgs.apartmentController.text = '4';
          addressArgs.setCoordinates(lat: 30.0, lng: 31.0);

          bool nextCalled = false;
          await tester.pumpWidget(
            buildTestWidget(currentIndex: 0, onNext: () => nextCalled = true),
          );
          await tester.pumpAndSettle();

          // Act
          await tester.tap(find.text(AppStrings.next));
          await tester.pumpAndSettle();

          // Assert
          expect(nextCalled, isTrue);
          verify(() => mockCheckoutCubit.setAddress(any())).called(1);
        },
      );

      testWidgets(
        'should call onNext directly when button is pressed on step 1',
        (tester) async {
          // Arrange
          bool nextCalled = false;
          await tester.pumpWidget(
            buildTestWidget(currentIndex: 1, onNext: () => nextCalled = true),
          );
          await tester.pumpAndSettle();

          // Act
          await tester.tap(find.text(AppStrings.next));
          await tester.pumpAndSettle();

          // Assert
          expect(nextCalled, isTrue);
        },
      );

      testWidgets(
        'should call cubit.addOrder when button is pressed on step 2 with cash payment',
        (tester) async {
          // Arrange
          await tester.pumpWidget(
            buildTestWidget(currentIndex: 2, onNext: () {}),
          );
          await tester.pumpAndSettle();

          // Act
          await tester.tap(find.text(AppStrings.confirmOrder));
          await tester.pumpAndSettle();

          // Assert
          verify(() => mockCheckoutCubit.addOrder()).called(1);
        },
      );

      testWidgets(
        'should call cubit.makePayment when button is pressed on step 2 with card payment',
        (tester) async {
          // Arrange
          when(
            () => mockCheckoutCubit.paymentOption,
          ).thenReturn(const PaymentOptionEntity(type: PaymentMethodType.card));

          await tester.pumpWidget(
            buildTestWidget(currentIndex: 2, onNext: () {}),
          );
          await tester.pumpAndSettle();

          // Act
          await tester.tap(find.text(AppStrings.confirmOrder));
          await tester.pumpAndSettle();

          // Assert
          verify(() => mockCheckoutCubit.makePayment()).called(1);
        },
      );
    });

    group('Listener Navigation and Toasts', () {
      testWidgets(
        'should clear cart and navigate to orderSuccessView on AddOrderSuccess',
        (tester) async {
          // Arrange
          await tester.pumpWidget(
            buildTestWidget(currentIndex: 2, onNext: () {}),
          );
          await tester.pumpAndSettle();

          // Act
          checkoutStateController.add(AddOrderSuccess());
          await tester.pump();
          await tester.pumpAndSettle();

          // Assert
          expect(
            find.text(AppStrings.orderPlacedSuccessfully, skipOffstage: false),
            findsOneWidget,
          );
          verify(() => mockCartCubit.clearCart()).called(1);
          expect(find.text('Order Success Screen'), findsOneWidget);

          toastification.dismissAll();
          await tester.pump(const Duration(seconds: 4));
        },
      );

      testWidgets('should show error toast when state is AddOrderFailure', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(currentIndex: 2, onNext: () {}),
        );
        await tester.pumpAndSettle();

        // Act
        const errorMessage = 'Network error placing order';
        checkoutStateController.add(AddOrderFailure(errorMessage));
        await tester.pump();
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(errorMessage, skipOffstage: false), findsOneWidget);

        toastification.dismissAll();
        await tester.pump(const Duration(seconds: 4));
      });
    });
  });
}
