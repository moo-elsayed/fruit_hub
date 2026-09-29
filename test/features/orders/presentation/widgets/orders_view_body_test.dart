import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_empty_state_widget.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/orders/presentation/managers/orders_cubit/orders_cubit.dart';
import 'package:fruit_hub/features/orders/presentation/managers/orders_cubit/orders_state.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/custom_order_item.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/orders_view_body.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockOrdersCubit extends MockCubit<OrdersState> implements OrdersCubit {}

void main() {
  late MockOrdersCubit mockOrdersCubit;

  const tOrder1 = OrderEntity(
    orderId: 101,
    status: OrderStatus.shipped,
    date: '2026-09-28T10:00:00Z',
    paymentOption: PaymentOptionEntity(
      type: PaymentMethodType.cash,
      shippingCost: 30.0,
    ),
    orderItems: [],
    totalPrice: 150.0,
  );

  const tOrder2 = OrderEntity(
    orderId: 102,
    status: OrderStatus.delivered,
    date: '2026-09-28T10:00:00Z',
    paymentOption: PaymentOptionEntity(
      type: PaymentMethodType.card,
      shippingCost: 0.0,
    ),
    orderItems: [],
    totalPrice: 200.0,
  );

  setUp(() {
    AppToast.isEnabled = false;
    mockOrdersCubit = MockOrdersCubit();

    when(() => mockOrdersCubit.state).thenReturn(const OrdersInitial());
    when(() => mockOrdersCubit.currentOrders).thenReturn([]);
  });

  tearDown(() {
    AppToast.isEnabled = true;
  });

  Widget buildTestWidget() => BlocProvider<OrdersCubit>.value(
    value: mockOrdersCubit,
    child: const Scaffold(body: OrdersViewBody()),
  );

  group('OrdersViewBody Widget Tests', () {
    testWidgets(
      'should show Skeletonizer when state is OrdersLoading and currentOrders is empty',
      (tester) async {
        when(() => mockOrdersCubit.state).thenReturn(const OrdersLoading());

        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );

        expect(
          find.byWidgetPredicate(
            (w) => w.runtimeType.toString().contains('Skeletonizer'),
          ),
          findsWidgets,
        );
        expect(find.byType(CustomOrderItem), findsNWidgets(3));
      },
    );

    testWidgets(
      'should show CustomEmptyStateWidget when state is OrdersSuccess with empty list',
      (tester) async {
        when(() => mockOrdersCubit.state).thenReturn(const OrdersSuccess([]));

        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );

        expect(find.byType(CustomEmptyStateWidget), findsOneWidget);
        expect(find.text(AppStrings.noOrdersYet), findsOneWidget);
        expect(find.text(AppStrings.noOrdersDescription), findsOneWidget);
        expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'should show list of CustomOrderItem when state is OrdersSuccess with orders',
      (tester) async {
        when(() => mockOrdersCubit.state)
            .thenReturn(const OrdersSuccess([tOrder1, tOrder2]));
        when(() => mockOrdersCubit.currentOrders)
            .thenReturn([tOrder1, tOrder2]);

        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CustomOrderItem), findsNWidgets(2));
      },
    );

    testWidgets(
      'should show error text when state is OrdersFailure and currentOrders is empty',
      (tester) async {
        const errorMessage = 'تعذر تحميل الطلبات، يرجى المحاولة لاحقاً';
        when(() => mockOrdersCubit.state)
            .thenReturn(const OrdersFailure(errorMessage));

        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );

        expect(find.text(errorMessage), findsOneWidget);
        expect(find.byType(CustomOrderItem), findsNothing);
      },
    );

    testWidgets(
      'should retain orders list when state is OrdersFailure but currentOrders is not empty',
      (tester) async {
        when(() => mockOrdersCubit.state)
            .thenReturn(const OrdersFailure('حدث خطأ'));
        when(() => mockOrdersCubit.currentOrders).thenReturn([tOrder1]);

        await tester.pumpWidget(
          createWidgetForTesting(child: buildTestWidget()),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CustomOrderItem), findsOneWidget);
      },
    );
  });
}
