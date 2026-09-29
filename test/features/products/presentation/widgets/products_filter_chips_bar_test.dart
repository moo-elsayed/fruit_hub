import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/product_category_filter.dart';
import 'package:fruit_hub/features/products/domain/entities/products_filter_entity.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/widgets/product_category_filter_chip.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_filter_chips_bar.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(ProductCategoryFilter.all);
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
      child: const ProductsFilterChipsBar(),
    ),
  );

  group('ProductsFilterChipsBar Widget Tests', () {
    testWidgets(
      'should render all product category chips and highlight active category',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockProductsCubit.currentFilter).thenReturn(
          const ProductsFilterEntity(
            categoryFilter: ProductCategoryFilter.organic,
          ),
        );

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // Assert
        expect(
          find.byType(ProductCategoryFilterChip),
          findsNWidgets(ProductCategoryFilter.values.length),
        );
        for (final category in ProductCategoryFilter.values) {
          expect(find.text(category.label), findsOneWidget);
        }

        // Verify the organic chip has isSelected = true
        final chipWidget = tester.widget<ProductCategoryFilterChip>(
          find.ancestor(
            of: find.text(ProductCategoryFilter.organic.label),
            matching: find.byType(ProductCategoryFilterChip),
          ),
        );
        expect(chipWidget.isSelected, isTrue);

        // Verify all chip has isSelected = false
        final allChipWidget = tester.widget<ProductCategoryFilterChip>(
          find.ancestor(
            of: find.text(ProductCategoryFilter.all.label),
            matching: find.byType(ProductCategoryFilterChip),
          ),
        );
        expect(allChipWidget.isSelected, isFalse);

        // Verify featured chip has isSelected = false
        final featuredChipWidget = tester.widget<ProductCategoryFilterChip>(
          find.ancestor(
            of: find.text(ProductCategoryFilter.featured.label),
            matching: find.byType(ProductCategoryFilterChip),
          ),
        );
        expect(featuredChipWidget.isSelected, isFalse);
      },
    );

    testWidgets(
      'should call cubit.setCategoryFilter when an unselected chip is tapped',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockProductsCubit.currentFilter).thenReturn(
          const ProductsFilterEntity(categoryFilter: ProductCategoryFilter.all),
        );
        when(() => mockProductsCubit.setCategoryFilter(any())).thenReturn(null);

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        await tester.tap(find.text(ProductCategoryFilter.featured.label));
        await tester.pump();

        // Assert
        verify(
          () => mockProductsCubit.setCategoryFilter(
            ProductCategoryFilter.featured,
          ),
        ).called(1);
      },
    );
  });
}
