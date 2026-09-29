import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/custom_action_button.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';
import 'package:fruit_hub/core/widgets/custom_quantity_selector.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/main/presentation/managers/main_tab_notifier.dart';
import 'package:fruit_hub/features/products/presentation/widgets/product_details_bottom_bar.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockCartCubit extends MockCubit<CartState> implements CartCubit {}

void main() {
  late MockCartCubit mockCartCubit;
  late ValueNotifier<int> quantityNotifier;

  const tFruit = FruitEntity(name: 'مانجو عويس', code: 'mango_01', price: 50.0);

  setUp(() {
    mockCartCubit = MockCartCubit();
    quantityNotifier = ValueNotifier<int>(1);

    when(() => mockCartCubit.state).thenReturn(CartInitial());
    when(() => mockCartCubit.getCartItem(tFruit.code)).thenReturn(null);
  });

  tearDown(() {
    quantityNotifier.dispose();
  });

  Widget buildTestWidget({
    required VoidCallback onAddToCart,
    Map<String, WidgetBuilder>? routes,
  }) => createWidgetForTesting(
    routes: routes,
    child: BlocProvider<CartCubit>.value(
      value: mockCartCubit,
      child: ProductDetailsBottomBar(
        fruit: tFruit,
        quantityNotifier: quantityNotifier,
        onAddToCart: onAddToCart,
      ),
    ),
  );

  group('ProductDetailsBottomBar Widget Tests', () {
    testWidgets(
      'should render Add to Cart button and initial quantity 1 when item is not in cart',
      (WidgetTester tester) async {
        // Arrange
        var addToCartCalled = false;
        await tester.pumpWidget(
          buildTestWidget(onAddToCart: () => addToCartCalled = true),
        );
        await tester.pump();

        // Assert
        expect(find.text(AppStrings.addToCart), findsOneWidget);
        expect(find.byType(CustomQuantitySelector), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        expect(find.byType(CustomPriceText), findsOneWidget);

        // Act - Tap add to cart
        await tester.tap(find.byType(CustomMaterialButton));
        await tester.pump();

        expect(addToCartCalled, isTrue);
      },
    );

    testWidgets(
      'should increment and decrement quantityNotifier when not in cart',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(onAddToCart: () {}));
        await tester.pump();

        // Act - Increment
        await tester.tap(find.byType(CustomActionButton).first);
        await tester.pump();

        // Assert
        expect(quantityNotifier.value, equals(2));
        expect(find.text('2'), findsOneWidget);

        // Act - Decrement
        await tester.tap(find.byType(CustomActionButton).last);
        await tester.pump();

        // Assert
        expect(quantityNotifier.value, equals(1));
        expect(find.text('1'), findsOneWidget);
      },
    );

    testWidgets(
      'should render View Cart button and interact with CartCubit when item is in cart',
      (WidgetTester tester) async {
        // Arrange
        const cartItem = CartItemEntity(fruitEntity: tFruit, quantity: 3);
        when(() => mockCartCubit.getCartItem(tFruit.code)).thenReturn(cartItem);
        when(() => mockCartCubit.incrementItemQuantity(tFruit.code))
            .thenReturn(null);
        when(() => mockCartCubit.decrementItemQuantity(tFruit.code))
            .thenReturn(null);

        await tester.pumpWidget(
          buildTestWidget(
            onAddToCart: () {},
            routes: {
              Routes.mainView: (_) => const Scaffold(body: Text('Main Screen')),
            },
          ),
        );
        await tester.pump();

        // Assert
        expect(find.text(AppStrings.viewCart), findsOneWidget);
        expect(find.text('3'), findsOneWidget);

        // Act - Increment
        await tester.tap(find.byType(CustomActionButton).first);
        await tester.pump();

        verify(() => mockCartCubit.incrementItemQuantity(tFruit.code))
            .called(1);

        // Act - Decrement
        await tester.tap(find.byType(CustomActionButton).last);
        await tester.pump();

        verify(() => mockCartCubit.decrementItemQuantity(tFruit.code))
            .called(1);

        // Act - Tap View Cart button
        await tester.tap(find.byType(CustomMaterialButton));
        await tester.pump();

        // Assert - MainTabNotifier switched to tab 2 (cart)
        expect(MainTabNotifier.currentTab.value, equals(2));
      },
    );
  });
}
