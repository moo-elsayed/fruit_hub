import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/widgets/custom_arrow_back.dart';
import 'package:fruit_hub/core/widgets/custom_favourite_icon.dart';
import 'package:fruit_hub/core/widgets/custom_network_image.dart';
import 'package:fruit_hub/features/favorites/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:fruit_hub/features/products/presentation/widgets/product_details_header.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockFavoriteCubit extends MockCubit<FavoriteState>
    implements FavoriteCubit {}

class FakeFruitEntity extends Fake implements FruitEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFruitEntity());
  });

  late MockFavoriteCubit mockFavoriteCubit;

  const tFruit = FruitEntity(
    name: 'رمان',
    code: 'pomegranate_01',
    price: 40.0,
    imagePath: 'https://example.com/pomegranate.png',
  );

  setUp(() {
    mockFavoriteCubit = MockFavoriteCubit();
    when(() => mockFavoriteCubit.state).thenReturn(FavoriteInitial());
    when(() => mockFavoriteCubit.isFavorite(any())).thenReturn(false);
    when(() => mockFavoriteCubit.toggleFavorite(any()))
        .thenAnswer((_) async {});
  });

  Widget buildTestWidget({required Widget child}) => createWidgetForTesting(
    child: BlocProvider<FavoriteCubit>.value(
      value: mockFavoriteCubit,
      child: child,
    ),
  );

  group('ProductDetailsHeader Widget Tests', () {
    testWidgets('should render back arrow, favourite icon, and network image', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(child: const ProductDetailsHeader(fruit: tFruit)),
      );
      await tester.pump();

      // Assert
      expect(find.byType(CustomArrowBack), findsOneWidget);
      expect(find.byType(CustomFavouriteIcon), findsOneWidget);
      expect(find.byType(CustomNetworkImage), findsOneWidget);
    });

    testWidgets('should call toggleFavorite when favourite icon is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTestWidget(child: const ProductDetailsHeader(fruit: tFruit)),
      );
      await tester.pump();

      await tester.tap(find.byType(CustomFavouriteIcon));
      await tester.pump();

      // Assert
      verify(() => mockFavoriteCubit.toggleFavorite(tFruit)).called(1);
    });

    testWidgets('should pop with fruit when back arrow is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange - Host behind navigation
      FruitEntity? poppedResult;
      await tester.pumpWidget(
        createWidgetForTesting(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<FruitEntity>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider<FavoriteCubit>.value(
                      value: mockFavoriteCubit,
                      child: const Scaffold(
                        body: ProductDetailsHeader(fruit: tFruit),
                      ),
                    ),
                  ),
                );
                poppedResult = result;
              },
              child: const Text('Open Header'),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Open Header'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(CustomArrowBack));
      await tester.pumpAndSettle();

      // Assert
      expect(poppedResult, equals(tFruit));
    });
  });
}
