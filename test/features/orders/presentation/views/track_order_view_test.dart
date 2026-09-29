import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_arrow_back.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/orders/presentation/managers/track_order_cubit/track_order_cubit.dart';
import 'package:fruit_hub/features/orders/presentation/managers/track_order_cubit/track_order_state.dart';
import 'package:fruit_hub/features/orders/presentation/views/track_order_view.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/track_order_view_body.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockTrackOrderCubit extends MockCubit<TrackOrderState>
    implements TrackOrderCubit {}

void main() {
  late MockTrackOrderCubit mockTrackOrderCubit;

  const tOrder = OrderEntity(
    orderId: 3001,
    status: OrderStatus.shipped,
    date: '2026-09-28T10:00:00Z',
    paymentOption: PaymentOptionEntity(
      type: PaymentMethodType.cash,
      shippingCost: 30.0,
    ),
    orderItems: [],
    totalPrice: 150.0,
  );

  setUp(() {
    AppToast.isEnabled = false;
    mockTrackOrderCubit = MockTrackOrderCubit();

    when(() => mockTrackOrderCubit.state)
        .thenReturn(const TrackOrderSuccess(tOrder));
    when(() => mockTrackOrderCubit.currentOrder).thenReturn(tOrder);
    when(() => mockTrackOrderCubit.close()).thenAnswer((_) async {});

    if (getIt.isRegistered<TrackOrderCubit>()) {
      getIt.unregister<TrackOrderCubit>();
    }
    getIt.registerFactoryParam<TrackOrderCubit, OrderEntity?, String?>(
      (param1, param2) => mockTrackOrderCubit,
    );
  });

  tearDown(() {
    AppToast.isEnabled = true;
    getIt.reset();
  });

  group('TrackOrderView Widget Tests', () {
    testWidgets(
      'should render CustomAppBar with trackOrder title, back arrow, and TrackOrderViewBody',
      (tester) async {
        await tester.pumpWidget(
          createWidgetForTesting(child: const TrackOrderView(order: tOrder)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CustomAppBar), findsOneWidget);
        expect(find.text(AppStrings.trackOrder), findsOneWidget);
        expect(find.byType(CustomArrowBack), findsOneWidget);
        expect(find.byType(TrackOrderViewBody), findsOneWidget);
      },
    );

    testWidgets(
      'should pop TrackOrderView when CustomArrowBack is tapped and Navigator can pop',
      (tester) async {
        await tester.pumpWidget(
          createWidgetForTesting(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TrackOrderView(order: tOrder),
                  ),
                ),
                child: const Text('Open Track View'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open TrackOrderView
        await tester.tap(find.text('Open Track View'));
        await tester.pumpAndSettle();
        expect(find.byType(TrackOrderView), findsOneWidget);

        // Tap back arrow
        await tester.tap(find.byType(CustomArrowBack));
        await tester.pumpAndSettle();

        expect(find.byType(TrackOrderView), findsNothing);
        expect(find.text('Open Track View'), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate to mainView when CustomArrowBack is tapped and cannot pop',
      (tester) async {
        var navigatedToMain = false;

        await tester.pumpWidget(
          createWidgetForTesting(
            routes: {
              Routes.mainView: (context) {
                navigatedToMain = true;
                return const Scaffold(body: Text('Main View'));
              },
            },
            child: const TrackOrderView(order: tOrder),
          ),
        );
        await tester.pumpAndSettle();

        // Tap back arrow
        await tester.tap(find.byType(CustomArrowBack));
        await tester.pumpAndSettle();

        expect(navigatedToMain, isTrue);
      },
    );
  });
}
