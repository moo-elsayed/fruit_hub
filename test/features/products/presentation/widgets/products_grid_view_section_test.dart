import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/custom_empty_state_widget.dart';
import 'package:fruit_hub/core/widgets/custom_fruit_item.dart';
import 'package:fruit_hub/core/widgets/fruits_grid_view.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/favorites/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:fruit_hub/features/products/domain/entities/products_filter_entity.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_grid_view_section.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

  const tFruit1 = FruitEntity(
    name: 'تفاح أحمر',
    code: 'apple_01',
    price: 30.0,
    isOrganic: true,
  );

  const tFruit2 = FruitEntity(
    name: 'موز أصفر',
    code: 'banana_02',
    price: 20.0,
    isFeatured: true,
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

    when(() => mockFavoriteCubit.state).thenReturn(FavoriteInitial());
    when(() => mockFavoriteCubit.isFavorite(any())).thenReturn(false);

    when(() => mockCartCubit.state).thenReturn(CartInitial());
  });

  Widget buildTestWidget({required ProductsState state}) {
    when(() => mockProductsCubit.state).thenReturn(state);

    return createWidgetForTesting(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ProductsCubit>.value(value: mockProductsCubit),
          BlocProvider<FavoriteCubit>.value(value: mockFavoriteCubit),
          BlocProvider<CartCubit>.value(value: mockCartCubit),
        ],
        child: const ProductsGridViewSection(),
      ),
    );
  }

  group('ProductsGridViewSection Widget Tests', () {
    testWidgets(
      'should render FruitsGridView shimmer when state is GetProductsLoading',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(state: GetProductsLoading()));
        await tester.pump();

        // Assert
        expect(find.byType(FruitsGridView), findsOneWidget);
        final skeletonizer = tester.widget<Skeletonizer>(
          find.byWidgetPredicate((widget) => widget is Skeletonizer),
        );
        expect(skeletonizer.enabled, isTrue);
      },
    );

    testWidgets(
      'should render error message when state is GetProductsFailure',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(state: GetProductsFailure('Something went wrong')),
        );
        await tester.pump();

        // Assert
        expect(find.text(AppStrings.tryAgainLater), findsOneWidget);
      },
    );

    testWidgets(
      'should render CustomEmptyStateWidget when GetProductsSuccess has empty fruits',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            state: GetProductsSuccess(
              fruits: const [],
              hasMore: false,
              filter: const ProductsFilterEntity(),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(CustomEmptyStateWidget), findsOneWidget);
        expect(find.text(AppStrings.noProductsFound), findsOneWidget);
      },
    );

    testWidgets(
      'should render CustomFruitItems when GetProductsSuccess contains fruits',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            state: GetProductsSuccess(
              fruits: const [tFruit1, tFruit2],
              hasMore: false,
              filter: const ProductsFilterEntity(),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(CustomFruitItem), findsNWidgets(2));
        expect(find.text('تفاح أحمر'), findsOneWidget);
        expect(find.text('موز أصفر'), findsOneWidget);
      },
    );

    testWidgets(
      'should render CupertinoActivityIndicator when isLoadingMore is true',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            state: GetProductsSuccess(
              fruits: const [tFruit1],
              hasMore: true,
              isLoadingMore: true,
              filter: const ProductsFilterEntity(),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      },
    );

    testWidgets('should trigger cubit.refresh on pull to refresh', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockProductsCubit.refresh()).thenAnswer((_) async {});

      await tester.pumpWidget(
        buildTestWidget(
          state: GetProductsSuccess(
            fruits: const [tFruit1, tFruit2],
            hasMore: false,
            filter: const ProductsFilterEntity(),
          ),
        ),
      );
      await tester.pump();

      // Act - Drag down past the threshold to trigger RefreshIndicator
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockProductsCubit.refresh()).called(1);
    });
  });
}
