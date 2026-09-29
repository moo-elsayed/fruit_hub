import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_empty_state_widget.dart';
import 'package:fruit_hub/core/widgets/custom_fruit_item.dart';
import 'package:fruit_hub/core/widgets/fruits_grid_view.dart';
import 'package:fruit_hub/core/widgets/main_screen_header.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/favorites/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:fruit_hub/features/favorites/presentation/views/favorites.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockFavoriteCubit extends MockCubit<FavoriteState>
    implements FavoriteCubit {}

class MockCartCubit extends MockCubit<CartState> implements CartCubit {}

void main() {
  late MockFavoriteCubit mockFavoriteCubit;
  late MockCartCubit mockCartCubit;

  const tFruit = FruitEntity(
    code: 'fruit_mango',
    name: 'مانجو عويس',
    price: 45.0,
    isOrganic: true,
  );

  setUp(() {
    AppToast.isEnabled = false;
    mockFavoriteCubit = MockFavoriteCubit();
    mockCartCubit = MockCartCubit();

    when(() => mockFavoriteCubit.state).thenReturn(FavoriteInitial());
    when(() => mockFavoriteCubit.favoriteFruits).thenReturn([]);
    when(() => mockFavoriteCubit.getFavorites()).thenAnswer((_) async {});
    when(() => mockFavoriteCubit.isFavorite(any())).thenReturn(true);
    when(() => mockFavoriteCubit.close()).thenAnswer((_) async {});

    when(() => mockCartCubit.state).thenReturn(CartInitial());
    when(() => mockCartCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    AppToast.isEnabled = true;
    toastification.dismissAll();
  });

  Widget buildTestWidget({bool withToastification = false}) =>
      createWidgetForTesting(
        withToastification: withToastification,
        routes: {
          Routes.productDetailsView: (context) =>
              const Scaffold(body: Text('Product Details Screen')),
        },
        child: MultiBlocProvider(
          providers: [
            BlocProvider<FavoriteCubit>.value(value: mockFavoriteCubit),
            BlocProvider<CartCubit>.value(value: mockCartCubit),
          ],
          child: const Favorites(),
        ),
      );

  group('Favorites View Widget Tests', () {
    testWidgets(
      'should call getFavorites on initState when favoriteFruits is empty',
      (tester) async {
        // Arrange
        when(() => mockFavoriteCubit.favoriteFruits).thenReturn([]);

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockFavoriteCubit.getFavorites()).called(1);
      },
    );

    testWidgets(
      'should not call getFavorites on initState when favoriteFruits is already loaded',
      (tester) async {
        // Arrange
        when(() => mockFavoriteCubit.favoriteFruits).thenReturn([tFruit]);

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        verifyNever(() => mockFavoriteCubit.getFavorites());
      },
    );

    testWidgets('should render MainScreenHeader with favorites title', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(MainScreenHeader), findsOneWidget);
      expect(
        find.widgetWithText(MainScreenHeader, AppStrings.favorites),
        findsOneWidget,
      );
    });

    testWidgets(
      'should render loading skeleton when state is GetFavoritesLoading and favoriteFruits is empty',
      (tester) async {
        // Arrange
        when(() => mockFavoriteCubit.favoriteFruits).thenReturn([]);
        when(() => mockFavoriteCubit.state).thenReturn(GetFavoritesLoading());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(FruitsGridView), findsOneWidget);
        final gridView = tester.widget<FruitsGridView>(
          find.byType(FruitsGridView),
        );
        expect(gridView.itemCount, 4);
      },
    );

    testWidgets(
      'should render CustomEmptyStateWidget when favorites is empty',
      (tester) async {
        // Arrange
        when(() => mockFavoriteCubit.favoriteFruits).thenReturn([]);

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CustomEmptyStateWidget), findsOneWidget);
        expect(find.text(AppStrings.noFavorites), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'should render fruits grid with favorite items when favoriteFruits is not empty',
      (tester) async {
        // Arrange
        when(() => mockFavoriteCubit.favoriteFruits).thenReturn([tFruit]);

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(FruitsGridView), findsOneWidget);
        expect(find.byType(CustomFruitItem), findsOneWidget);
        expect(find.text(tFruit.name), findsOneWidget);
        expect(find.byType(CustomEmptyStateWidget), findsNothing);
      },
    );

    testWidgets(
      'should navigate to productDetailsView when favorite item is tapped',
      (tester) async {
        // Arrange
        when(() => mockFavoriteCubit.favoriteFruits).thenReturn([tFruit]);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byType(CustomFruitItem));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Product Details Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'should show error toast with errorMessage when GetFavoritesFailure is emitted',
      (tester) async {
        // Arrange
        AppToast.isEnabled = true;
        final favoriteController = StreamController<FavoriteState>.broadcast();
        whenListen(
          mockFavoriteCubit,
          favoriteController.stream,
          initialState: FavoriteInitial(),
        );

        await tester.pumpWidget(buildTestWidget(withToastification: true));
        await tester.pumpAndSettle();

        // Act
        favoriteController.add(GetFavoritesFailure('فشل في جلب قائمة المفضلة'));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        // Assert
        expect(
          find.text('فشل في جلب قائمة المفضلة', skipOffstage: false),
          findsOneWidget,
        );

        toastification.dismissAll();
        await tester.pump(const Duration(seconds: 4));
        await favoriteController.close();
      },
    );

    testWidgets(
      'should show error toast with errorMessage when ToggleFavoriteFailure is emitted',
      (tester) async {
        // Arrange
        AppToast.isEnabled = true;
        final favoriteController = StreamController<FavoriteState>.broadcast();
        whenListen(
          mockFavoriteCubit,
          favoriteController.stream,
          initialState: FavoriteInitial(),
        );

        await tester.pumpWidget(buildTestWidget(withToastification: true));
        await tester.pumpAndSettle();

        // Act
        favoriteController.add(ToggleFavoriteFailure('فشل في تعديل المفضلة'));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        // Assert
        expect(
          find.text('فشل في تعديل المفضلة', skipOffstage: false),
          findsOneWidget,
        );

        toastification.dismissAll();
        await tester.pump(const Duration(seconds: 4));
        await favoriteController.close();
      },
    );
  });
}
