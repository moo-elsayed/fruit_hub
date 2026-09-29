import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/features/products/domain/entities/products_filter_entity.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_filter_button.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_filter_chips_bar.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_header_bar.dart';
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

  group('ProductsHeaderBar Widget Tests', () {
    testWidgets(
      'should render ProductsFilterChipsBar and ProductsFilterButton',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: BlocProvider<ProductsCubit>.value(
              value: mockProductsCubit,
              child: const ProductsHeaderBar(),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(ProductsFilterChipsBar), findsOneWidget);
        expect(find.byType(ProductsFilterButton), findsOneWidget);
      },
    );
  });
}
