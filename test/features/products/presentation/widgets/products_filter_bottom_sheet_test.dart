import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/product_sort_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/products/domain/entities/products_filter_entity.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_filter_bottom_sheet.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_reset_sort_button.dart';
import 'package:fruit_hub/features/products/presentation/widgets/sort_option_item.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

class FakeProductsFilterEntity extends Fake implements ProductsFilterEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeProductsFilterEntity());
    registerFallbackValue(ProductSortType.none);
  });

  late MockProductsCubit mockProductsCubit;

  setUp(() {
    mockProductsCubit = MockProductsCubit();
    when(() => mockProductsCubit.state).thenReturn(ProductsInitial());
    when(() => mockProductsCubit.currentFilter)
        .thenReturn(const ProductsFilterEntity());
  });

  Widget buildTestWidget() => createWidgetForTesting(
    child: BlocProvider<ProductsCubit>.value(
      value: mockProductsCubit,
      child: const ProductsFilterBottomSheet(),
    ),
  );

  group('ProductsFilterBottomSheet Widget Tests', () {
    testWidgets(
      'should render title, apply button, and all non-none sort options',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // Assert
        expect(find.text(AppStrings.sortBy), findsOneWidget);
        expect(find.text(AppStrings.apply), findsOneWidget);

        final expectedSortOptions = ProductSortType.values.where(
          (t) => t != ProductSortType.none,
        );
        expect(
          find.byType(SortOptionItem),
          findsNWidgets(expectedSortOptions.length),
        );
        for (final sort in expectedSortOptions) {
          expect(find.text(sort.title), findsOneWidget);
        }
      },
    );

    testWidgets(
      'should select a sort option when tapped and display reset button',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // Initially no sort is selected, reset button should be hidden
        expect(find.byType(ProductsResetSortButton), findsNothing);

        // Act - Tap on Price: Lowest to Highest
        await tester.tap(find.text(ProductSortType.priceLowestToHighest.title));
        await tester.pump();

        // Assert - Reset button appears
        expect(find.byType(ProductsResetSortButton), findsOneWidget);

        // Act - Tap Reset button
        await tester.tap(find.byType(ProductsResetSortButton));
        await tester.pump();

        // Assert - Reset button disappears
        expect(find.byType(ProductsResetSortButton), findsNothing);
      },
    );

    testWidgets(
      'should call cubit.applyFilter when Apply button is pressed with selected sort',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockProductsCubit.applyFilter(any())).thenReturn(null);

        // Wrap with a host to test pop on apply
        await tester.pumpWidget(
          createWidgetForTesting(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ProductsFilterBottomSheet.show(
                  context,
                  productsCubit: mockProductsCubit,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.pump();

        // Open bottom sheet
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(ProductsFilterBottomSheet), findsOneWidget);

        // Select a sort option
        await tester.tap(find.text(ProductSortType.priceHighestToLowest.title));
        await tester.pump();

        // Tap apply button
        await tester.tap(find.byType(CustomMaterialButton));
        await tester.pumpAndSettle();

        // Assert
        verify(
          () => mockProductsCubit.applyFilter(
            any(
              that: isA<ProductsFilterEntity>().having(
                (f) => f.sortType,
                'sortType',
                ProductSortType.priceHighestToLowest,
              ),
            ),
          ),
        ).called(1);

        // Verify bottom sheet is dismissed
        expect(find.byType(ProductsFilterBottomSheet), findsNothing);
      },
    );
  });
}
