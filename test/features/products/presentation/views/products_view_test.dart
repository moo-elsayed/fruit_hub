import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_arrow_back.dart';
import 'package:fruit_hub/core/widgets/custom_fruit_item.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/favorites/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:fruit_hub/features/products/domain/entities/products_filter_entity.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/views/products_view.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_grid_view_section.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_header_bar.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

class MockFavoriteCubit extends MockCubit<FavoriteState>
    implements FavoriteCubit {}

class MockCartCubit extends MockCubit<CartState> implements CartCubit {}

void main() {
  late MockProductsCubit mockProductsCubit;
  late MockFavoriteCubit mockFavoriteCubit;
  late MockCartCubit mockCartCubit;

  const tFruit = FruitEntity(
    name: 'برتقال بلدي',
    code: 'orange_01',
    price: 25.0,
    isOrganic: true,
  );

  setUp(() {
    mockProductsCubit = MockProductsCubit();
    mockFavoriteCubit = MockFavoriteCubit();
    mockCartCubit = MockCartCubit();

    when(() => mockProductsCubit.state).thenReturn(ProductsInitial());
    when(() => mockProductsCubit.currentFilter)
        .thenReturn(const ProductsFilterEntity());
    when(() => mockProductsCubit.hasMore).thenReturn(false);
    when(() => mockProductsCubit.isLoadingMore).thenReturn(false);
    when(() => mockProductsCubit.fetchFirstPage()).thenAnswer((_) async {});

    when(() => mockFavoriteCubit.state).thenReturn(FavoriteInitial());
    when(() => mockFavoriteCubit.isFavorite(any())).thenReturn(false);

    when(() => mockCartCubit.state).thenReturn(CartInitial());
  });

  Widget buildProductsViewWithProviders() => MultiBlocProvider(
    providers: [
      BlocProvider<ProductsCubit>.value(value: mockProductsCubit),
      BlocProvider<FavoriteCubit>.value(value: mockFavoriteCubit),
      BlocProvider<CartCubit>.value(value: mockCartCubit),
    ],
    child: const ProductsView(),
  );

  Widget buildTestWidget({required ProductsState state}) {
    when(() => mockProductsCubit.state).thenReturn(state);
    return createWidgetForTesting(child: buildProductsViewWithProviders());
  }

  group('ProductsView Widget Tests', () {
    testWidgets('should call fetchFirstPage on initState', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(state: ProductsInitial()));
      await tester.pump();

      // Assert
      verify(() => mockProductsCubit.fetchFirstPage()).called(1);
    });

    testWidgets(
      'should render CustomAppBar with title and back arrow, ProductsHeaderBar, and ProductsGridViewSection',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(state: ProductsInitial()));
        await tester.pump();

        // Assert
        expect(find.byType(CustomAppBar), findsOneWidget);
        expect(find.text(AppStrings.ourProducts), findsOneWidget);
        expect(find.byType(CustomArrowBack), findsOneWidget);
        expect(find.byType(ProductsHeaderBar), findsOneWidget);
        expect(find.byType(ProductsGridViewSection), findsOneWidget);
      },
    );

    testWidgets('should pop ProductsView when back arrow is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange - Host ProductsView behind a route push
      await tester.pumpWidget(
        createWidgetForTesting(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => buildProductsViewWithProviders(),
                ),
              ),
              child: const Text('Open Products'),
            ),
          ),
        ),
      );
      await tester.pump();

      // Navigate to ProductsView
      await tester.tap(find.text('Open Products'));
      await tester.pumpAndSettle();

      expect(find.byType(ProductsView), findsOneWidget);

      // Act - Tap back arrow
      await tester.tap(find.byType(CustomArrowBack));
      await tester.pumpAndSettle();

      // Assert - ProductsView is popped
      expect(find.byType(ProductsView), findsNothing);
      expect(find.text('Open Products'), findsOneWidget);
    });

    testWidgets(
      'should display products list when state is GetProductsSuccess',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            state: GetProductsSuccess(
              fruits: const [tFruit],
              hasMore: false,
              filter: const ProductsFilterEntity(),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(CustomFruitItem), findsOneWidget);
        expect(find.text('برتقال بلدي'), findsOneWidget);
      },
    );
  });
}
