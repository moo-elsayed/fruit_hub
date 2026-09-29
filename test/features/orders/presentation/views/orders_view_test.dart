import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_arrow_back.dart';
import 'package:fruit_hub/features/orders/presentation/managers/orders_cubit/orders_cubit.dart';
import 'package:fruit_hub/features/orders/presentation/managers/orders_cubit/orders_state.dart';
import 'package:fruit_hub/features/orders/presentation/views/orders_view.dart';
import 'package:fruit_hub/features/orders/presentation/widgets/orders_view_body.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockOrdersCubit extends MockCubit<OrdersState> implements OrdersCubit {}

void main() {
  late MockOrdersCubit mockOrdersCubit;

  setUp(() {
    AppToast.isEnabled = false;
    mockOrdersCubit = MockOrdersCubit();

    when(() => mockOrdersCubit.state).thenReturn(const OrdersSuccess([]));
    when(() => mockOrdersCubit.currentOrders).thenReturn([]);
    when(() => mockOrdersCubit.streamOrders()).thenReturn(null);
    when(() => mockOrdersCubit.close()).thenAnswer((_) async {});

    if (getIt.isRegistered<OrdersCubit>()) {
      getIt.unregister<OrdersCubit>();
    }
    getIt.registerFactory<OrdersCubit>(() => mockOrdersCubit);
  });

  tearDown(() {
    AppToast.isEnabled = true;
    getIt.reset();
  });

  group('OrdersView Widget Tests', () {
    testWidgets(
      'should render CustomAppBar with myOrders title, back arrow, and OrdersViewBody',
      (tester) async {
        await tester.pumpWidget(
          createWidgetForTesting(child: const OrdersView()),
        );

        expect(find.byType(CustomAppBar), findsOneWidget);
        expect(find.text(AppStrings.myOrders), findsOneWidget);
        expect(find.byType(CustomArrowBack), findsOneWidget);
        expect(find.byType(OrdersViewBody), findsOneWidget);
        verify(() => mockOrdersCubit.streamOrders()).called(1);
      },
    );

    testWidgets('should pop OrdersView when CustomArrowBack is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetForTesting(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const OrdersView())),
              child: const Text('Open Orders'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open OrdersView
      await tester.tap(find.text('Open Orders'));
      await tester.pumpAndSettle();
      expect(find.byType(OrdersView), findsOneWidget);

      // Tap back arrow
      await tester.tap(find.byType(CustomArrowBack));
      await tester.pumpAndSettle();

      expect(find.byType(OrdersView), findsNothing);
      expect(find.text('Open Orders'), findsOneWidget);
    });
  });
}
