import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_arrow_back.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/favorites/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:fruit_hub/features/products/presentation/managers/product_details_cubit/product_details_cubit.dart';
import 'package:fruit_hub/features/products/presentation/views/product_details_view.dart';
import 'package:fruit_hub/features/products/presentation/widgets/product_details_bottom_bar.dart';
import 'package:fruit_hub/features/products/presentation/widgets/product_details_grid_view.dart';
import 'package:fruit_hub/features/products/presentation/widgets/product_details_header.dart';
import 'package:fruit_hub/features/products/presentation/widgets/product_details_info_section.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockProductDetailsCubit extends MockCubit<ProductDetailsState>
    implements ProductDetailsCubit {}

class MockCartCubit extends MockCubit<CartState> implements CartCubit {}

class MockFavoriteCubit extends MockCubit<FavoriteState>
    implements FavoriteCubit {}

class FakeFruitEntity extends Fake implements FruitEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFruitEntity());
  });

  late MockProductDetailsCubit mockProductDetailsCubit;
  late MockCartCubit mockCartCubit;
  late MockFavoriteCubit mockFavoriteCubit;

  const tFruit = FruitEntity(
    name: 'أفوكادو',
    code: 'avocado_01',
    description: 'أفوكادو طازج صحي ومغذي',
    price: 60.0,
    isOrganic: true,
  );

  setUp(() {
    mockProductDetailsCubit = MockProductDetailsCubit();
    mockCartCubit = MockCartCubit();
    mockFavoriteCubit = MockFavoriteCubit();

    when(() => mockProductDetailsCubit.state)
        .thenReturn(ProductDetailsInitial());
    when(() => mockProductDetailsCubit.getProductDetails(any()))
        .thenAnswer((_) async {});

    when(() => mockCartCubit.state).thenReturn(CartInitial());
    when(() => mockCartCubit.getCartItem(any())).thenReturn(null);
    when(
      () =>
          mockCartCubit.addItemToCart(any(), quantity: any(named: 'quantity')),
    ).thenAnswer((_) async {});

    when(() => mockFavoriteCubit.state).thenReturn(FavoriteInitial());
    when(() => mockFavoriteCubit.isFavorite(any())).thenReturn(false);
  });

  Widget buildProductDetailsViewWithProviders({
    FruitEntity? fruitEntity,
    String? fruitCode,
  }) => MultiBlocProvider(
    providers: [
      BlocProvider<ProductDetailsCubit>.value(value: mockProductDetailsCubit),
      BlocProvider<CartCubit>.value(value: mockCartCubit),
      BlocProvider<FavoriteCubit>.value(value: mockFavoriteCubit),
    ],
    child: ProductDetailsView(fruitEntity: fruitEntity, fruitCode: fruitCode),
  );

  Widget buildTestWidget({
    required ProductDetailsState state,
    FruitEntity? fruitEntity,
    String? fruitCode,
  }) {
    when(() => mockProductDetailsCubit.state).thenReturn(state);
    return createWidgetForTesting(
      child: buildProductDetailsViewWithProviders(
        fruitEntity: fruitEntity,
        fruitCode: fruitCode,
      ),
    );
  }

  group('ProductDetailsView Widget Tests', () {
    testWidgets(
      'should call getProductDetails on initState when fruitCode or fruitEntity is provided',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            state: ProductDetailsInitial(),
            fruitCode: 'avocado_01',
          ),
        );
        await tester.pump();

        // Assert
        verify(() => mockProductDetailsCubit.getProductDetails('avocado_01'))
            .called(1);
      },
    );

    testWidgets(
      'should render error screen when state is ProductDetailsFailure and fruit is null',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            state: ProductDetailsFailure('Failed to load product details'),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(CustomAppBar), findsOneWidget);
        expect(find.text(AppStrings.productDetails), findsOneWidget);
        expect(find.text('Failed to load product details'), findsOneWidget);
      },
    );

    testWidgets('should render Skeletonizer enabled when product is loading', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(
          state: ProductDetailsLoading(),
          fruitCode: 'avocado_01',
        ),
      );
      await tester.pump();

      // Assert
      final skeletonizer = tester.widget<Skeletonizer>(
        find.byWidgetPredicate((widget) => widget is Skeletonizer),
      );
      expect(skeletonizer.enabled, isTrue);
    });

    testWidgets(
      'should render all details widgets when fruitEntity is passed directly',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(state: ProductDetailsInitial(), fruitEntity: tFruit),
        );
        await tester.pump();

        // Assert
        expect(find.byType(ProductDetailsHeader), findsOneWidget);
        expect(find.byType(ProductDetailsInfoSection), findsOneWidget);
        expect(find.byType(ProductDetailsGridView), findsOneWidget);
        expect(find.byType(ProductDetailsBottomBar), findsOneWidget);
        expect(find.text('أفوكادو'), findsOneWidget);
      },
    );

    testWidgets(
      'should render details widgets when state is ProductDetailsSuccess',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            state: ProductDetailsSuccess(tFruit),
            fruitCode: tFruit.code,
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(ProductDetailsHeader), findsOneWidget);
        expect(find.byType(ProductDetailsInfoSection), findsOneWidget);
        expect(find.byType(ProductDetailsGridView), findsOneWidget);
        expect(find.byType(ProductDetailsBottomBar), findsOneWidget);
        expect(find.text('أفوكادو'), findsOneWidget);
      },
    );

    testWidgets(
      'should call cartCubit.addItemToCart when add to cart button is pressed',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            state: ProductDetailsSuccess(tFruit),
            fruitEntity: tFruit,
          ),
        );
        await tester.pump();

        // Act - Tap Add to Cart button in bottom bar
        await tester.tap(find.byType(CustomMaterialButton));
        await tester.pump();

        // Assert
        verify(() => mockCartCubit.addItemToCart(tFruit, quantity: 1))
            .called(1);
      },
    );

    testWidgets('should pop with currentFruit when back arrow is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange - Host behind navigation route
      FruitEntity? poppedResult;
      await tester.pumpWidget(
        createWidgetForTesting(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<FruitEntity>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => buildProductDetailsViewWithProviders(
                      fruitEntity: tFruit,
                    ),
                  ),
                );
                poppedResult = result;
              },
              child: const Text('Open Details'),
            ),
          ),
        ),
      );
      await tester.pump();

      // Navigate to details view
      await tester.tap(find.text('Open Details'));
      await tester.pumpAndSettle();

      expect(find.byType(ProductDetailsView), findsOneWidget);

      // Act - Tap back arrow in header
      await tester.tap(find.byType(CustomArrowBack));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ProductDetailsView), findsNothing);
      expect(poppedResult, equals(tFruit));
    });
  });
}
