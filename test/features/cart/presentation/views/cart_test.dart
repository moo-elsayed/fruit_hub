import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/custom_empty_state_widget.dart';
import 'package:fruit_hub/core/widgets/main_screen_header.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/cart/presentation/views/cart.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_checkout_bottom_bar.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_header_badge.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_items_list_view.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/free_shipping_progress_bar.dart';
import 'package:fruit_hub/features/checkout/domain/entities/shipping_config_entity.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockCartCubit extends MockCubit<CartState> implements CartCubit {}

void main() {
  late MockCartCubit mockCartCubit;

  setUp(() {
    mockCartCubit = MockCartCubit();
    when(() => mockCartCubit.getProductsInCart()).thenAnswer((_) async {});
    when(() => mockCartCubit.productsInCart).thenReturn([]);
    when(() => mockCartCubit.shippingConfig).thenReturn(null);
  });

  const dummyFruit1 = FruitEntity(
    name: 'Strawberry',
    code: 'strawberry_1',
    price: 30.0,
  );

  const dummyFruit2 = FruitEntity(
    name: 'Banana',
    code: 'banana_2',
    price: 20.0,
  );

  const dummyItems = [
    CartItemEntity(fruitEntity: dummyFruit1, quantity: 2),
    CartItemEntity(fruitEntity: dummyFruit2, quantity: 3),
  ];

  group('Cart View Widget Tests', () {
    testWidgets('should call getProductsInCart on initState', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockCartCubit.state).thenReturn(CartInitial());

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: BlocProvider<CartCubit>.value(
            value: mockCartCubit,
            child: const Cart(),
          ),
        ),
      );
      await tester.pump();

      // Assert
      verify(() => mockCartCubit.getProductsInCart()).called(1);
    });

    testWidgets('should render Skeletonizer when state is CartLoading', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockCartCubit.state).thenReturn(CartLoading());

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: BlocProvider<CartCubit>.value(
            value: mockCartCubit,
            child: const Cart(),
          ),
        ),
      );
      await tester.pump();

      // Assert
      final listView = tester.widget<CartItemsListView>(
        find.byType(CartItemsListView),
      );
      expect(listView.itemCount, equals(3));
      expect(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString().contains('Skeletonizer'),
        ),
        findsWidgets,
      );
      expect(find.byType(CartHeaderBadge), findsNothing);
      expect(find.byType(CustomEmptyStateWidget), findsNothing);
    });

    testWidgets('should render CustomEmptyStateWidget when cart has no items', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockCartCubit.state).thenReturn(
        CartSuccess(items: const [], totalPrice: 0, totalItemCount: 0),
      );

      // Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: BlocProvider<CartCubit>.value(
            value: mockCartCubit,
            child: const Cart(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CustomEmptyStateWidget), findsOneWidget);
      expect(find.text(AppStrings.shoppingCart), findsOneWidget);
      expect(find.text(AppStrings.emptyCartSubtitle), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      expect(find.byType(CartHeaderBadge), findsNothing);
      expect(find.byType(CartCheckoutBottomBar), findsNothing);
      expect(find.byType(FreeShippingProgressBar), findsNothing);
    });

    testWidgets(
      'should render items, header badge, free shipping bar, and checkout bar when CartSuccess has items and threshold',
      (WidgetTester tester) async {
        // Arrange
        const shippingConfig = ShippingConfigEntity(freeShippingThreshold: 200);
        when(() => mockCartCubit.state).thenReturn(
          CartSuccess(
            items: dummyItems,
            totalPrice: 120,
            totalItemCount: 5,
            shippingConfig: shippingConfig,
          ),
        );

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: BlocProvider<CartCubit>.value(
              value: mockCartCubit,
              child: const Cart(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(MainScreenHeader), findsOneWidget);
        expect(find.byType(CartHeaderBadge), findsOneWidget);
        expect(find.text('2 ${AppStrings.products}'), findsOneWidget);
        expect(find.byType(FreeShippingProgressBar), findsOneWidget);
        expect(find.byType(CartItemsListView), findsOneWidget);
        expect(find.byType(CartCheckoutBottomBar), findsOneWidget);
        expect(find.byType(CustomEmptyStateWidget), findsNothing);
        expect(find.byType(Skeletonizer), findsNothing);
      },
    );

    testWidgets(
      'should omit FreeShippingProgressBar when freeShippingThreshold is null or zero',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockCartCubit.state).thenReturn(
          CartSuccess(
            items: dummyItems,
            totalPrice: 120,
            totalItemCount: 5,
            shippingConfig: const ShippingConfigEntity(
              freeShippingThreshold: null,
            ),
          ),
        );

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: BlocProvider<CartCubit>.value(
              value: mockCartCubit,
              child: const Cart(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(FreeShippingProgressBar), findsNothing);
        expect(find.byType(CartItemsListView), findsOneWidget);
        expect(find.byType(CartCheckoutBottomBar), findsOneWidget);
      },
    );
  });
}
