import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_arrow_back.dart';
import 'package:fruit_hub/features/search/presentation/managers/search_cubit/search_cubit.dart';
import 'package:fruit_hub/features/search/presentation/views/search_view.dart';
import 'package:fruit_hub/features/search/presentation/widgets/search_view_body.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockSearchCubit extends MockCubit<SearchState> implements SearchCubit {}

void main() {
  late MockSearchCubit mockSearchCubit;

  setUp(() {
    mockSearchCubit = MockSearchCubit();
    when(() => mockSearchCubit.state).thenReturn(SearchInitial());
    when(() => mockSearchCubit.resetSearch()).thenReturn(null);

    if (getIt.isRegistered<SearchCubit>()) {
      getIt.unregister<SearchCubit>();
    }
    getIt.registerFactory<SearchCubit>(() => mockSearchCubit);
  });

  tearDown(() {
    if (getIt.isRegistered<SearchCubit>()) {
      getIt.unregister<SearchCubit>();
    }
  });

  group('SearchView Widget Tests', () {
    testWidgets(
      'should render CustomAppBar with search title, back arrow, and SearchViewBody',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(child: const SearchView()),
        );
        await tester.pump(const Duration(milliseconds: 400));

        // Assert
        expect(find.byType(CustomAppBar), findsOneWidget);
        expect(find.text(AppStrings.search), findsOneWidget);
        expect(find.byType(CustomArrowBack), findsOneWidget);
        expect(find.byType(SearchViewBody), findsOneWidget);
      },
    );

    testWidgets('should pop SearchView when CustomArrowBack is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange - Host SearchView behind a navigation push
      await tester.pumpWidget(
        createWidgetForTesting(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const SearchView())),
              child: const Text('Open Search'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Open SearchView
      await tester.tap(find.text('Open Search'));
      await tester.pumpAndSettle();
      expect(find.byType(SearchView), findsOneWidget);

      // Act - Tap back arrow
      await tester.tap(find.byType(CustomArrowBack));
      await tester.pumpAndSettle();

      // Assert - SearchView popped
      expect(find.byType(SearchView), findsNothing);
      expect(find.text('Open Search'), findsOneWidget);
    });
  });
}
