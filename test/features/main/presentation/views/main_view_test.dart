import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/cubits/app_language_cubit.dart';
import 'package:fruit_hub/core/cubits/app_theme_cubit.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signout_cubit/sign_out_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/cart/presentation/views/cart.dart';
import 'package:fruit_hub/features/favorites/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:fruit_hub/features/favorites/presentation/views/favorites.dart';
import 'package:fruit_hub/features/home/presentation/managers/home_cubit/home_cubit.dart';
import 'package:fruit_hub/features/home/presentation/views/home.dart';
import 'package:fruit_hub/features/main/presentation/managers/main_tab_notifier.dart';
import 'package:fruit_hub/features/main/presentation/views/main_view.dart';
import 'package:fruit_hub/features/main/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:fruit_hub/features/main/presentation/widgets/custom_bottom_navigation_bar_item_widget.dart';
import 'package:fruit_hub/features/notifications/presentation/managers/notifications_cubit/notifications_cubit.dart';
import 'package:fruit_hub/features/notifications/presentation/managers/notifications_cubit/notifications_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toastification/toastification.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockAppThemeCubit extends MockCubit<ThemeMode> implements AppThemeCubit {}

class MockAppLanguageCubit extends MockCubit<Locale>
    implements AppLanguageCubit {}

class MockCartCubit extends MockCubit<CartState> implements CartCubit {}

class MockFavoriteCubit extends MockCubit<FavoriteState>
    implements FavoriteCubit {}

class MockNotificationsCubit extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

class MockUserInfoCubit extends MockCubit<UserInfoState>
    implements UserInfoCubit {}

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class MockSignOutCubit extends MockCubit<SignOutState>
    implements SignOutCubit {}

void main() {
  late MockAppThemeCubit mockAppThemeCubit;
  late MockAppLanguageCubit mockAppLanguageCubit;
  late MockCartCubit mockCartCubit;
  late MockFavoriteCubit mockFavoriteCubit;
  late MockNotificationsCubit mockNotificationsCubit;
  late MockUserInfoCubit mockUserInfoCubit;
  late MockHomeCubit mockHomeCubit;
  late MockSignOutCubit mockSignOutCubit;

  setUp(() {
    AppToast.isEnabled = false;
    mockAppThemeCubit = MockAppThemeCubit();
    mockAppLanguageCubit = MockAppLanguageCubit();
    mockCartCubit = MockCartCubit();
    mockFavoriteCubit = MockFavoriteCubit();
    mockNotificationsCubit = MockNotificationsCubit();
    mockUserInfoCubit = MockUserInfoCubit();
    mockHomeCubit = MockHomeCubit();
    mockSignOutCubit = MockSignOutCubit();

    when(() => mockAppThemeCubit.state).thenReturn(ThemeMode.light);
    when(() => mockAppThemeCubit.close()).thenAnswer((_) async {});

    when(() => mockAppLanguageCubit.state).thenReturn(const Locale('en'));
    when(() => mockAppLanguageCubit.close()).thenAnswer((_) async {});

    when(() => mockCartCubit.state).thenReturn(CartInitial());
    when(() => mockCartCubit.productsInCart).thenReturn([]);
    when(() => mockCartCubit.shippingConfig).thenReturn(null);
    when(() => mockCartCubit.getProductsInCart()).thenAnswer((_) async {});
    when(() => mockCartCubit.close()).thenAnswer((_) async {});

    when(() => mockFavoriteCubit.state).thenReturn(FavoriteInitial());
    when(() => mockFavoriteCubit.favoriteFruits).thenReturn([]);
    when(() => mockFavoriteCubit.getFavorites()).thenAnswer((_) async {});
    when(() => mockFavoriteCubit.close()).thenAnswer((_) async {});

    when(() => mockNotificationsCubit.state)
        .thenReturn(const NotificationsInitial());
    when(() => mockNotificationsCubit.close()).thenAnswer((_) async {});

    when(() => mockUserInfoCubit.state).thenReturn(UserInfoInitial());
    when(() => mockUserInfoCubit.currentUser).thenReturn(null);
    when(() => mockUserInfoCubit.close()).thenAnswer((_) async {});

    when(() => mockHomeCubit.state).thenReturn(HomeInitial());
    when(() => mockHomeCubit.getBestSellerProducts()).thenAnswer((_) async {});
    when(() => mockHomeCubit.close()).thenAnswer((_) async {});

    when(() => mockSignOutCubit.state).thenReturn(SignOutInitial());
    when(() => mockSignOutCubit.close()).thenAnswer((_) async {});

    if (getIt.isRegistered<HomeCubit>()) {
      getIt.unregister<HomeCubit>();
    }
    getIt.registerFactory<HomeCubit>(() => mockHomeCubit);

    if (getIt.isRegistered<SignOutCubit>()) {
      getIt.unregister<SignOutCubit>();
    }
    getIt.registerFactory<SignOutCubit>(() => mockSignOutCubit);

    MainTabNotifier.currentTab.value = 0;
  });

  tearDown(() {
    AppToast.isEnabled = true;
    toastification.dismissAll();
    getIt.reset();
  });

  Widget buildTestWidget({
    int initialIndex = 0,
    bool withToastification = false,
  }) => createWidgetForTesting(
    withToastification: withToastification,
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AppThemeCubit>.value(value: mockAppThemeCubit),
        BlocProvider<AppLanguageCubit>.value(value: mockAppLanguageCubit),
        BlocProvider<CartCubit>.value(value: mockCartCubit),
        BlocProvider<FavoriteCubit>.value(value: mockFavoriteCubit),
        BlocProvider<NotificationsCubit>.value(value: mockNotificationsCubit),
        BlocProvider<UserInfoCubit>.value(value: mockUserInfoCubit),
      ],
      child: MainView(initialIndex: initialIndex),
    ),
  );

  group('MainView Widget Tests', () {
    testWidgets(
      'should render CustomBottomNavigationBar and initial Home tab by default',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CustomBottomNavigationBar), findsOneWidget);
        expect(find.byType(Home), findsOneWidget);
        expect(MainTabNotifier.currentTab.value, 0);

        final indexedStackFinder = find.byType(IndexedStack);
        expect(indexedStackFinder, findsOneWidget);
        final indexedStackWidget = tester.widget<IndexedStack>(
          indexedStackFinder,
        );
        expect(indexedStackWidget.index, 0);
      },
    );

    testWidgets('should render with specified initialIndex tab', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget(initialIndex: 2));
      await tester.pumpAndSettle();

      // Assert
      expect(MainTabNotifier.currentTab.value, 2);
      expect(find.byType(Cart), findsOneWidget);

      final indexedStackFinder = find.byType(IndexedStack);
      final indexedStackWidget = tester.widget<IndexedStack>(
        indexedStackFinder,
      );
      expect(indexedStackWidget.index, 2);
    });

    testWidgets('should switch tab when bottom navigation bar item is tapped', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(MainTabNotifier.currentTab.value, 0);

      // Act - Tap on the 2nd tab (Favorites, index 1)
      final favoritesTab = find.byType(CustomBottomNavigationItemWidget).at(1);
      await tester.tap(favoritesTab);
      await tester.pumpAndSettle();

      // Assert
      expect(MainTabNotifier.currentTab.value, 1);
      expect(find.byType(Favorites), findsOneWidget);

      final indexedStackFinder = find.byType(IndexedStack);
      final indexedStackWidget = tester.widget<IndexedStack>(
        indexedStackFinder,
      );
      expect(indexedStackWidget.index, 1);
    });

    testWidgets(
      'should switch to tab 0 on back pop when currentIndex is not 0',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Switch to Cart tab (index 2)
        MainTabNotifier.switchToTab(2);
        await tester.pumpAndSettle();
        expect(MainTabNotifier.currentTab.value, 2);

        // Act - simulate device back press
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // Assert
        expect(MainTabNotifier.currentTab.value, 0);
      },
    );

    testWidgets('should update tab when widget initialIndex changes', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget(initialIndex: 0));
      await tester.pumpAndSettle();
      expect(MainTabNotifier.currentTab.value, 0);

      // Act - update initialIndex to 3
      await tester.pumpWidget(buildTestWidget(initialIndex: 3));
      await tester.pumpAndSettle();

      // Assert
      expect(MainTabNotifier.currentTab.value, 3);
    });

    testWidgets(
      'should show success toast with itemAddedToCart when newItemAdded is true',
      (tester) async {
        // Arrange
        AppToast.isEnabled = true;
        final cartController = StreamController<CartState>.broadcast();
        whenListen(
          mockCartCubit,
          cartController.stream,
          initialState: CartInitial(),
        );

        await tester.pumpWidget(buildTestWidget(withToastification: true));
        await tester.pumpAndSettle();

        // Act
        cartController.add(
          CartSuccess(
            items: const [],
            totalPrice: 0,
            totalItemCount: 0,
            newItemAdded: true,
          ),
        );
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        // Assert
        expect(
          find.text(AppStrings.itemAddedToCart, skipOffstage: false),
          findsOneWidget,
        );

        toastification.dismissAll();
        await tester.pump(const Duration(seconds: 4));
        await cartController.close();
      },
    );

    testWidgets(
      'should show success toast with itemRemovedFromCart when itemRemoved is true',
      (tester) async {
        // Arrange
        AppToast.isEnabled = true;
        final cartController = StreamController<CartState>.broadcast();
        whenListen(
          mockCartCubit,
          cartController.stream,
          initialState: CartInitial(),
        );

        await tester.pumpWidget(buildTestWidget(withToastification: true));
        await tester.pumpAndSettle();

        // Act
        cartController.add(
          CartSuccess(
            items: const [],
            totalPrice: 0,
            totalItemCount: 0,
            itemRemoved: true,
          ),
        );
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        // Assert
        expect(
          find.text(AppStrings.itemRemovedFromCart, skipOffstage: false),
          findsOneWidget,
        );

        toastification.dismissAll();
        await tester.pump(const Duration(seconds: 4));
        await cartController.close();
      },
    );

    testWidgets(
      'should show warning toast with itemAlreadyInCart when itemAlreadyExists is true',
      (tester) async {
        // Arrange
        AppToast.isEnabled = true;
        final cartController = StreamController<CartState>.broadcast();
        whenListen(
          mockCartCubit,
          cartController.stream,
          initialState: CartInitial(),
        );

        await tester.pumpWidget(buildTestWidget(withToastification: true));
        await tester.pumpAndSettle();

        // Act
        cartController.add(
          CartSuccess(
            items: const [],
            totalPrice: 0,
            totalItemCount: 0,
            itemAlreadyExists: true,
          ),
        );
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        // Assert
        expect(
          find.text(AppStrings.itemAlreadyInCart, skipOffstage: false),
          findsOneWidget,
        );

        toastification.dismissAll();
        await tester.pump(const Duration(seconds: 4));
        await cartController.close();
      },
    );

    testWidgets(
      'should show error toast with errorMessage when CartFailure occurs',
      (tester) async {
        // Arrange
        AppToast.isEnabled = true;
        final cartController = StreamController<CartState>.broadcast();
        whenListen(
          mockCartCubit,
          cartController.stream,
          initialState: CartInitial(),
        );

        await tester.pumpWidget(buildTestWidget(withToastification: true));
        await tester.pumpAndSettle();

        // Act
        cartController.add(CartFailure('Cart error occurred'));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        // Assert
        expect(
          find.text('Cart error occurred', skipOffstage: false),
          findsOneWidget,
        );

        toastification.dismissAll();
        await tester.pump(const Duration(seconds: 4));
        await cartController.close();
      },
    );
  });
}
