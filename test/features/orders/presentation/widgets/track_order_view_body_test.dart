import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/entities/order_item_entity.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/order_timeline_preview.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/orders/presentation/managers/track_order_cubit/track_order_cubit.dart';
import 'package:fruit_hub/features/orders/presentation/managers/track_order_cubit/track_order_state.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_card_header.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_customer_details.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_financial_summary.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/order_products_list.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/track_order_loading_skeleton.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/track_order_view_body.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockTrackOrderCubit extends MockCubit<TrackOrderState>
    implements TrackOrderCubit {}

void main() {
  late MockTrackOrderCubit mockTrackOrderCubit;

  const tAddress = AddressEntity(
    city: 'القاهرة',
    streetName: 'شارع التحرير',
    phone: '01012345678',
  );

  const tItems = [
    OrderItemEntity(
      name: 'تفاح أحمر',
      price: 40.0,
      quantity: 2,
      code: 'apple_01',
    ),
  ];

  const tLivePendingOrder = OrderEntity(
    orderId: 2001,
    status: OrderStatus.pending,
    date: '2026-09-28T10:00:00Z',
    shippingAddress: tAddress,
    paymentOption: PaymentOptionEntity(
      type: PaymentMethodType.cash,
      shippingCost: 30.0,
    ),
    orderItems: tItems,
    totalPrice: 110.0,
  );

  const tShippedOrder = OrderEntity(
    orderId: 2002,
    status: OrderStatus.shipped,
    date: '2026-09-28T10:00:00Z',
    shippingAddress: tAddress,
    paymentOption: PaymentOptionEntity(
      type: PaymentMethodType.card,
      shippingCost: 30.0,
    ),
    orderItems: tItems,
    totalPrice: 110.0,
  );

  const tCancelledOrder = OrderEntity(
    orderId: 2003,
    status: OrderStatus.cancelled,
    date: '2026-09-28T10:00:00Z',
    shippingAddress: tAddress,
    paymentOption: PaymentOptionEntity(
      type: PaymentMethodType.paypal,
      shippingCost: 30.0,
    ),
    orderItems: tItems,
    totalPrice: 110.0,
  );

  setUp(() {
    AppToast.isEnabled = false;
    mockTrackOrderCubit = MockTrackOrderCubit();

    when(() => mockTrackOrderCubit.state).thenReturn(const TrackOrderInitial());
    when(() => mockTrackOrderCubit.currentOrder).thenReturn(null);
  });

  tearDown(() {
    AppToast.isEnabled = true;
  });

  Widget buildTestWidget() => BlocProvider<TrackOrderCubit>.value(
    value: mockTrackOrderCubit,
    child: const Scaffold(body: TrackOrderViewBody()),
  );

  group('TrackOrderViewBody Widget Tests', () {
    testWidgets(
      'should show TrackOrderLoadingSkeleton when state is TrackOrderLoading and currentOrder is null',
      (tester) async {
        when(() => mockTrackOrderCubit.state)
            .thenReturn(const TrackOrderLoading());
        when(() => mockTrackOrderCubit.currentOrder).thenReturn(null);

        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );

        expect(find.byType(TrackOrderLoadingSkeleton), findsOneWidget);
      },
    );

    testWidgets(
      'should show error message when state is TrackOrderFailure and currentOrder is null',
      (tester) async {
        const errorMsg = 'تعذر العثور على الطلب';
        when(() => mockTrackOrderCubit.state)
            .thenReturn(const TrackOrderFailure(errorMsg));
        when(() => mockTrackOrderCubit.currentOrder).thenReturn(null);

        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );

        expect(find.text(errorMsg), findsOneWidget);
        expect(find.byType(TrackOrderLoadingSkeleton), findsNothing);
      },
    );

    testWidgets(
      'should render full order details and timeline when order is live',
      (tester) async {
        when(() => mockTrackOrderCubit.state)
            .thenReturn(const TrackOrderSuccess(tShippedOrder));
        when(() => mockTrackOrderCubit.currentOrder).thenReturn(tShippedOrder);

        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OrderCardHeader), findsOneWidget);
        expect(find.byType(OrderTimelinePreview), findsOneWidget);
        expect(find.byType(OrderCustomerDetails), findsOneWidget);
        expect(find.byType(OrderProductsList), findsOneWidget);
        expect(find.byType(OrderFinancialSummary), findsOneWidget);
        expect(find.text(AppStrings.orderCancelled), findsNothing);
      },
    );

    testWidgets(
      'should render orderCancelled banner instead of timeline when order is cancelled',
      (tester) async {
        when(() => mockTrackOrderCubit.state)
            .thenReturn(const TrackOrderSuccess(tCancelledOrder));
        when(() => mockTrackOrderCubit.currentOrder)
            .thenReturn(tCancelledOrder);

        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.orderCancelled), findsNWidgets(2));
        expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
        expect(find.byType(OrderTimelinePreview), findsNothing);
      },
    );

    testWidgets(
      'should render cancel button and trigger cubit when order is pending (canCancel)',
      (tester) async {
        when(() => mockTrackOrderCubit.state)
            .thenReturn(const TrackOrderSuccess(tLivePendingOrder));
        when(() => mockTrackOrderCubit.currentOrder)
            .thenReturn(tLivePendingOrder);
        when(() => mockTrackOrderCubit.cancelCurrentOrder())
            .thenAnswer((_) async {});

        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pumpAndSettle();

        final cancelButton = find.byType(CustomMaterialButton);
        expect(cancelButton, findsOneWidget);
        expect(find.text(AppStrings.cancelOrder), findsOneWidget);

        // Tap cancel order button to open confirmation dialog
        await tester.ensureVisible(cancelButton);
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();

        // Confirmation dialog should appear
        expect(find.text(AppStrings.cancelOrderConfirm), findsOneWidget);

        // Tap confirm in dialog
        final confirmBtn = find.text(AppStrings.cancelOrder).last;
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        verify(() => mockTrackOrderCubit.cancelCurrentOrder()).called(1);
      },
    );
  });
}
