import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/enums/product_sort_type.dart';
import 'package:fruit_hub/core/theming/colors_manager.dart';
import 'package:fruit_hub/features/products/domain/entities/products_filter_entity.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_filter_bottom_sheet.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_filter_button.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

void main() {
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
      child: const Scaffold(body: Center(child: ProductsFilterButton())),
    ),
  );

  group('ProductsFilterButton Widget Tests', () {
    testWidgets(
      'should render filter svg icon and show inactive style when hasActiveSort is false',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockProductsCubit.currentFilter).thenReturn(
          const ProductsFilterEntity(sortType: ProductSortType.none),
        );

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(ProductsFilterButton), findsOneWidget);
        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = container.decoration as BoxDecoration;
        final border = decoration.border as Border;
        final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));

        expect(decoration.color, LightColors().surface);
        expect(border.top.color, LightColors().border);
        expect(svg.colorFilter, isNull);
      },
    );

    testWidgets('should render active style when hasActiveSort is true', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockProductsCubit.currentFilter).thenReturn(
        const ProductsFilterEntity(
          sortType: ProductSortType.priceLowestToHighest,
        ),
      );

      // Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Assert
      expect(find.byType(ProductsFilterButton), findsOneWidget);
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));

      expect(decoration.color, LightColors().primary.withValues(alpha: 0.1));
      expect(border.top.color, LightColors().primary);
      expect(
        svg.colorFilter,
        ColorFilter.mode(LightColors().primary, BlendMode.srcIn),
      );
    });

    testWidgets('should open ProductsFilterBottomSheet when tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockProductsCubit.currentFilter)
          .thenReturn(const ProductsFilterEntity());

      // Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.byType(ProductsFilterButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ProductsFilterBottomSheet), findsOneWidget);
    });
  });
}
