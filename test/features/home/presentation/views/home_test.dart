import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/custom_fruit_item.dart';
import 'package:fruit_hub/core/widgets/fruits_grid_view.dart';
import 'package:fruit_hub/core/widgets/search_text_field.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/favorites/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:fruit_hub/features/home/presentation/managers/home_cubit/home_cubit.dart';
import 'package:fruit_hub/features/home/presentation/views/home.dart';
import 'package:fruit_hub/features/home/presentation/widgets/custom_home_app_bar.dart';
import 'package:fruit_hub/features/home/presentation/widgets/custom_section_header.dart';
import 'package:fruit_hub/features/notifications/presentation/managers/notifications_cubit/notifications_cubit.dart';
import 'package:fruit_hub/features/notifications/presentation/managers/notifications_cubit/notifications_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class MockUserInfoCubit extends MockCubit<UserInfoState>
    implements UserInfoCubit {}

class MockNotificationsCubit extends MockCubit<NotificationsState>
    implements NotificationsCubit {}

class MockFavoriteCubit extends MockCubit<FavoriteState>
    implements FavoriteCubit {}

class MockCartCubit extends MockCubit<CartState> implements CartCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;
  late MockUserInfoCubit mockUserInfoCubit;
  late MockNotificationsCubit mockNotificationsCubit;
  late MockFavoriteCubit mockFavoriteCubit;
  late MockCartCubit mockCartCubit;

  const tFruit = FruitEntity(
    code: 'apple_01',
    name: 'تفاح أحمر',
    price: 30.0,
    isOrganic: true,
  );

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    mockUserInfoCubit = MockUserInfoCubit();
    mockNotificationsCubit = MockNotificationsCubit();
    mockFavoriteCubit = MockFavoriteCubit();
    mockCartCubit = MockCartCubit();

    when(() => mockHomeCubit.state).thenReturn(HomeInitial());
    when(() => mockHomeCubit.getBestSellerProducts()).thenAnswer((_) async {});

    when(() => mockUserInfoCubit.state).thenReturn(UserInfoInitial());
    when(() => mockUserInfoCubit.currentUser)
        .thenReturn(const UserEntity(uid: 'u1', name: 'محمد'));

    when(() => mockNotificationsCubit.state)
        .thenReturn(const NotificationsInitial());

    when(() => mockFavoriteCubit.state).thenReturn(FavoriteInitial());
    when(() => mockFavoriteCubit.isFavorite(any())).thenReturn(false);

    when(() => mockCartCubit.state).thenReturn(CartInitial());
  });

  tearDown(() {
    mockHomeCubit.close();
    mockUserInfoCubit.close();
    mockNotificationsCubit.close();
    mockFavoriteCubit.close();
    mockCartCubit.close();
  });

  Widget buildTestWidget() => createWidgetForTesting(
    routes: {
      Routes.searchView: (context) =>
          const Scaffold(body: Text('Search Screen')),
      Routes.productsView: (context) =>
          const Scaffold(body: Text('Products Screen')),
      Routes.productDetailsView: (context) =>
          const Scaffold(body: Text('Product Details Screen')),
    },
    child: MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>.value(value: mockHomeCubit),
        BlocProvider<UserInfoCubit>.value(value: mockUserInfoCubit),
        BlocProvider<NotificationsCubit>.value(value: mockNotificationsCubit),
        BlocProvider<FavoriteCubit>.value(value: mockFavoriteCubit),
        BlocProvider<CartCubit>.value(value: mockCartCubit),
      ],
      child: const Home(),
    ),
  );

  group('Home View Widget Tests', () {
    testWidgets('should call getBestSellerProducts on initState', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockHomeCubit.getBestSellerProducts()).called(1);
    });

    testWidgets(
      'should render CustomHomeAppBar, SearchTextField, and CustomSectionHeader',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CustomHomeAppBar), findsOneWidget);
        expect(find.byType(SearchTextField), findsOneWidget);
        expect(find.byType(CustomSectionHeader), findsOneWidget);
        expect(find.text(AppStrings.bestSeller), findsOneWidget);
      },
    );

    testWidgets('should navigate to searchView when search bar is tapped', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(SearchTextField));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Search Screen'), findsOneWidget);
    });

    testWidgets('should navigate to productsView when more text is tapped', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text(AppStrings.more));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Products Screen'), findsOneWidget);
    });

    testWidgets(
      'should render loading skeleton when state is GetBestSellerProductsLoading',
      (tester) async {
        // Arrange
        when(() => mockHomeCubit.state)
            .thenReturn(GetBestSellerProductsLoading());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(FruitsGridView), findsOneWidget);
        final gridView = tester.widget<FruitsGridView>(
          find.byType(FruitsGridView),
        );
        expect(gridView.itemCount, 6);
      },
    );

    testWidgets(
      'should render fruits grid when state is GetBestSellerProductsSuccess',
      (tester) async {
        // Arrange
        when(() => mockHomeCubit.state)
            .thenReturn(GetBestSellerProductsSuccess([tFruit]));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(FruitsGridView), findsOneWidget);
        expect(find.byType(CustomFruitItem), findsOneWidget);
        expect(find.text(tFruit.name), findsOneWidget);
      },
    );

    testWidgets(
      'should render error message when state is GetBestSellerProductsFailure',
      (tester) async {
        // Arrange
        when(
          () => mockHomeCubit.state,
        ).thenReturn(GetBestSellerProductsFailure('حدث خطأ في تحميل البيانات'));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('حدث خطأ في تحميل البيانات'), findsOneWidget);
      },
    );

    testWidgets(
      'should render tryAgainLater message when state is unexpected',
      (tester) async {
        // Arrange
        when(() => mockHomeCubit.state).thenReturn(HomeInitial());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(AppStrings.tryAgainLater), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate to productDetailsView when fruit item is tapped',
      (tester) async {
        // Arrange
        when(() => mockHomeCubit.state)
            .thenReturn(GetBestSellerProductsSuccess([tFruit]));

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byType(CustomFruitItem));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Product Details Screen'), findsOneWidget);
      },
    );
  });
}
