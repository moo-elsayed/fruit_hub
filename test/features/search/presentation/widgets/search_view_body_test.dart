import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/custom_empty_state_widget.dart';
import 'package:fruit_hub/core/widgets/fruits_grid_view.dart';
import 'package:fruit_hub/core/widgets/search_text_field.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/favorites/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:fruit_hub/features/search/presentation/managers/search_cubit/search_cubit.dart';
import 'package:fruit_hub/features/search/presentation/widgets/search_view_body.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockSearchCubit extends MockCubit<SearchState> implements SearchCubit {}

class MockFavoriteCubit extends MockCubit<FavoriteState>
    implements FavoriteCubit {}

class MockCartCubit extends MockCubit<CartState> implements CartCubit {}

void main() {
  late MockSearchCubit mockSearchCubit;
  late MockFavoriteCubit mockFavoriteCubit;
  late MockCartCubit mockCartCubit;

  const tQuery = 'تفاح';

  const tFruit = FruitEntity(
    name: 'تفاح أحمر',
    description: 'تفاح أحمر طازج',
    price: 25.0,
    imagePath: '',
    code: 'APPLE_01',
    isFeatured: true,
    avgRating: 4.5,
    ratingCount: 15,
    isOrganic: true,
    daysUntilExpiration: 10,
    weightInGrams: 500,
    numberOfCalories: 52,
    reviews: [],
  );

  setUp(() {
    mockSearchCubit = MockSearchCubit();
    mockFavoriteCubit = MockFavoriteCubit();
    mockCartCubit = MockCartCubit();

    when(() => mockSearchCubit.state).thenReturn(SearchInitial());
    when(() => mockSearchCubit.resetSearch()).thenReturn(null);
    when(() => mockSearchCubit.searchProducts(any())).thenAnswer((_) async {});

    when(() => mockFavoriteCubit.state).thenReturn(FavoriteInitial());
    when(() => mockFavoriteCubit.isFavorite(any())).thenReturn(false);

    when(() => mockCartCubit.state).thenReturn(CartInitial());
  });

  Widget buildTestWidget() => createWidgetForTesting(
    child: MultiBlocProvider(
      providers: [
        BlocProvider<SearchCubit>.value(value: mockSearchCubit),
        BlocProvider<FavoriteCubit>.value(value: mockFavoriteCubit),
        BlocProvider<CartCubit>.value(value: mockCartCubit),
      ],
      child: const SearchViewBody(),
    ),
  );

  group('SearchViewBody Initial & Interaction Tests', () {
    testWidgets(
      'should render SearchTextField with placeholder hint and empty body when query is empty',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump(const Duration(milliseconds: 400));

        // Assert
        expect(find.byType(SearchTextField), findsOneWidget);
        expect(find.text(AppStrings.searchFor), findsOneWidget);
        expect(find.byType(FruitsGridView), findsNothing);
        expect(find.byType(CustomEmptyStateWidget), findsNothing);
        expect(find.text(AppStrings.searchResults), findsNothing);
      },
    );

    testWidgets(
      'should debounce search input and call searchProducts only after 500ms delay',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pump(const Duration(milliseconds: 400));

        // Act - Enter text
        await tester.enterText(find.byType(TextField), tQuery);
        await tester.pump();

        // Advance 400ms (less than 500ms debounce)
        await tester.pump(const Duration(milliseconds: 400));

        // Assert - Not called yet
        verifyNever(() => mockSearchCubit.searchProducts(any()));

        // Act - Advance remaining 100ms
        await tester.pump(const Duration(milliseconds: 100));

        // Assert - Called once after 500ms
        verify(() => mockSearchCubit.searchProducts(tQuery)).called(1);
      },
    );

    testWidgets(
      'should debounce rapid keystrokes and only search for the final query',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pump(const Duration(milliseconds: 400));

        // Act - Type initial character
        await tester.enterText(find.byType(TextField), 'ت');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Act - Type full query before 500ms elapsed
        await tester.enterText(find.byType(TextField), tQuery);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Assert - Only final query searched
        verifyNever(() => mockSearchCubit.searchProducts('ت'));
        verify(() => mockSearchCubit.searchProducts(tQuery)).called(1);
      },
    );

    testWidgets(
      'should reset search and cancel pending debounce when query is cleared or empty',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pump(const Duration(milliseconds: 400));

        // Act - Enter query
        await tester.enterText(find.byType(TextField), tQuery);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Act - Clear query before debounce completes
        await tester.enterText(find.byType(TextField), '');
        await tester.pump();

        // Assert - Reset search called
        verify(() => mockSearchCubit.resetSearch())
            .called(greaterThanOrEqualTo(1));

        // Advance past debounce duration to ensure search was cancelled
        await tester.pump(const Duration(milliseconds: 500));
        verifyNever(() => mockSearchCubit.searchProducts(any()));
      },
    );

    testWidgets(
      'should show clear icon when text is entered and clear input and reset search when tapped',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pump(const Duration(milliseconds: 400));

        // Initially clear icon is not visible
        expect(find.byIcon(Icons.close_rounded), findsNothing);

        // Act - Enter text
        await tester.enterText(find.byType(TextField), tQuery);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Assert - Clear icon appears
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);

        // Act - Tap clear icon
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();

        // Assert - Search field cleared and resetSearch called
        expect(find.text(tQuery), findsNothing);
        verify(() => mockSearchCubit.resetSearch())
            .called(greaterThanOrEqualTo(1));
      },
    );
  });

  group('SearchViewBody State Rendering Tests', () {
    testWidgets(
      'should render SizedBox.shrink when query is empty even if state is SearchLoading or SearchSuccess',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockSearchCubit.state)
            .thenReturn(SearchSuccess(const [tFruit]));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump(const Duration(milliseconds: 400));

        // Assert - Nothing displayed because search text is empty
        expect(find.byType(FruitsGridView), findsNothing);
        expect(find.byType(CustomEmptyStateWidget), findsNothing);
        expect(find.text(AppStrings.searchResults), findsNothing);
      },
    );

    testWidgets(
      'should render Skeletonizer FruitsGridView with 4 items when state is SearchLoading and query is not empty',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockSearchCubit.state).thenReturn(SearchLoading());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump(const Duration(milliseconds: 400));
        await tester.enterText(find.byType(TextField), tQuery);
        await tester.pump();

        // Assert
        expect(find.byType(FruitsGridView), findsOneWidget);
        final gridView = tester.widget<FruitsGridView>(
          find.byType(FruitsGridView),
        );
        expect(gridView.itemCount, equals(4));
        expect(find.byType(CustomEmptyStateWidget), findsNothing);
        expect(find.text(AppStrings.searchResults), findsNothing);

        // Advance debounce timer to clean up
        await tester.pump(const Duration(milliseconds: 500));
      },
    );

    testWidgets(
      'should render search results header and fruit items when state is SearchSuccess with fruits',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockSearchCubit.state)
            .thenReturn(SearchSuccess(const [tFruit]));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump(const Duration(milliseconds: 400));
        await tester.enterText(find.byType(TextField), tQuery);
        await tester.pump();

        // Assert
        expect(find.text(AppStrings.searchResults), findsOneWidget);
        expect(find.byType(FruitsGridView), findsOneWidget);
        expect(find.text(tFruit.name), findsOneWidget);
        expect(find.byType(CustomEmptyStateWidget), findsNothing);

        // Advance debounce timer to clean up
        await tester.pump(const Duration(milliseconds: 500));
      },
    );

    testWidgets(
      'should render CustomEmptyStateWidget when state is SearchSuccess with empty fruit list',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockSearchCubit.state).thenReturn(SearchSuccess(const []));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump(const Duration(milliseconds: 400));
        await tester.enterText(find.byType(TextField), tQuery);
        await tester.pump();

        // Assert
        expect(find.byType(CustomEmptyStateWidget), findsOneWidget);
        expect(find.byType(FruitsGridView), findsNothing);
        expect(find.text(AppStrings.searchResults), findsNothing);

        // Advance debounce timer to clean up
        await tester.pump(const Duration(milliseconds: 500));
      },
    );

    testWidgets(
      'should render CustomEmptyStateWidget when state is SearchFailure',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockSearchCubit.state)
            .thenReturn(SearchFailure('Error loading search'));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump(const Duration(milliseconds: 400));
        await tester.enterText(find.byType(TextField), tQuery);
        await tester.pump();

        // Assert
        expect(find.byType(CustomEmptyStateWidget), findsOneWidget);
        expect(find.byType(FruitsGridView), findsNothing);
        expect(find.text(AppStrings.searchResults), findsNothing);

        // Advance debounce timer to clean up
        await tester.pump(const Duration(milliseconds: 500));
      },
    );
  });
}
