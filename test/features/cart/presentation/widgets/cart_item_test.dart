import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/custom_action_button.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_item.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockCartCubit extends MockCubit<CartState> implements CartCubit {}

void main() {
  late MockCartCubit mockCartCubit;

  setUp(() {
    mockCartCubit = MockCartCubit();
    when(() => mockCartCubit.state).thenReturn(CartInitial());
  });

  const dummyFruit = FruitEntity(
    name: 'Fresh Mango',
    code: 'mango_01',
    price: 40.0,
    imagePath: '',
  );

  const dummyCartItem = CartItemEntity(fruitEntity: dummyFruit, quantity: 2);

  group('CartItem Widget Tests', () {
    testWidgets('should render fruit details, quantity, and price accurately', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetForTesting(
          child: BlocProvider<CartCubit>.value(
            value: mockCartCubit,
            child: const CartItem(cartItemEntity: dummyCartItem),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Fresh Mango'), findsOneWidget);
      expect(
        find.text('40 ${AppStrings.pounds} / ${AppStrings.kilo}'),
        findsOneWidget,
      );
      expect(find.text('2'), findsOneWidget);
      expect(find.byType(CustomPriceText), findsOneWidget);
    });

    testWidgets('should call removeItemFromCart when trash button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockCartCubit.removeItemFromCart(dummyFruit.code))
          .thenAnswer((_) async {});

      await tester.pumpWidget(
        createWidgetForTesting(
          child: BlocProvider<CartCubit>.value(
            value: mockCartCubit,
            child: const CartItem(cartItemEntity: dummyCartItem),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap the trash icon specifically
      final trashFinder = find.byWidgetPredicate(
        (widget) =>
            widget is SvgPicture &&
            widget.bytesLoader is SvgAssetLoader &&
            (widget.bytesLoader as SvgAssetLoader).assetName ==
                AppAssets.iconsTrash,
      );
      await tester.tap(trashFinder);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockCartCubit.removeItemFromCart(dummyFruit.code)).called(1);
    });

    testWidgets(
      'should call incrementItemQuantity and decrementItemQuantity when selector buttons tapped',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockCartCubit.incrementItemQuantity(dummyFruit.code))
            .thenReturn(null);
        when(() => mockCartCubit.decrementItemQuantity(dummyFruit.code))
            .thenReturn(null);

        await tester.pumpWidget(
          createWidgetForTesting(
            child: BlocProvider<CartCubit>.value(
              value: mockCartCubit,
              child: const CartItem(cartItemEntity: dummyCartItem),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act - Tap increment (first CustomActionButton)
        await tester.tap(find.byType(CustomActionButton).first);
        await tester.pumpAndSettle();

        // Assert increment
        verify(() => mockCartCubit.incrementItemQuantity(dummyFruit.code))
            .called(1);

        // Act - Tap decrement (second CustomActionButton)
        await tester.tap(find.byType(CustomActionButton).last);
        await tester.pumpAndSettle();

        // Assert decrement
        verify(() => mockCartCubit.decrementItemQuantity(dummyFruit.code))
            .called(1);
      },
    );

    testWidgets('should navigate to productDetailsView when card is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      Object? capturedArguments;

      await tester.pumpWidget(
        createWidgetForTesting(
          onGenerateRoute: (settings) {
            if (settings.name == Routes.productDetailsView) {
              capturedArguments = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Product Details')),
              );
            }
            return null;
          },
          child: BlocProvider<CartCubit>.value(
            value: mockCartCubit,
            child: const CartItem(cartItemEntity: dummyCartItem),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap the outer card InkWell
      await tester.tap(find.text('Fresh Mango'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Product Details'), findsOneWidget);
      expect(capturedArguments, equals(dummyFruit));
    });
  });
}
