import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/entities/review_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/price_per_kilo.dart';
import 'package:fruit_hub/core/widgets/product_badge.dart';
import 'package:fruit_hub/features/products/presentation/managers/product_details_cubit/product_details_cubit.dart';
import 'package:fruit_hub/features/products/presentation/widgets/product_details_info_section.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockProductDetailsCubit extends MockCubit<ProductDetailsState>
    implements ProductDetailsCubit {}

void main() {
  late MockProductDetailsCubit mockProductDetailsCubit;

  const tFruit = FruitEntity(
    name: 'كيوي نيوزيلندي',
    code: 'kiwi_01',
    description: 'كيوي طازج غني بفيتامين سي',
    price: 45.0,
    avgRating: 4.8,
    isOrganic: true,
    isFeatured: true,
    reviews: [
      ReviewEntity(
        name: 'أحمد',
        image: '',
        description: 'رائع',
        date: '2026-09-20',
        rating: 5,
        userId: 'u1',
      ),
    ],
  );

  setUp(() {
    mockProductDetailsCubit = MockProductDetailsCubit();
    when(() => mockProductDetailsCubit.state)
        .thenReturn(ProductDetailsInitial());
  });

  Widget buildTestWidget({
    required Widget child,
    Map<String, WidgetBuilder>? routes,
  }) => createWidgetForTesting(
    routes: routes,
    child: BlocProvider<ProductDetailsCubit>.value(
      value: mockProductDetailsCubit,
      child: child,
    ),
  );

  group('ProductDetailsInfoSection Widget Tests', () {
    testWidgets(
      'should render name, price, rating, reviews count, description, and badges',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildTestWidget(
            child: const ProductDetailsInfoSection(fruit: tFruit),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.text('كيوي نيوزيلندي'), findsOneWidget);
        expect(find.byType(PricePerKilo), findsOneWidget);
        expect(find.text('4.8'), findsOneWidget);
        expect(find.text('(1 ${AppStrings.reviews})'), findsOneWidget);
        expect(find.text('كيوي طازج غني بفيتامين سي'), findsOneWidget);
        expect(
          find.byType(ProductBadge),
          findsNWidgets(2),
        ); // Organic and Featured
      },
    );

    testWidgets('should navigate to reviewsView when reviews row is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      var navigatedToReviews = false;
      await tester.pumpWidget(
        buildTestWidget(
          routes: {
            Routes.reviewsView: (_) {
              navigatedToReviews = true;
              return const Scaffold(body: Text('Reviews View Screen'));
            },
          },
          child: const ProductDetailsInfoSection(fruit: tFruit),
        ),
      );
      await tester.pump();

      // Act - Tap on reviews row
      await tester.tap(find.text('(1 ${AppStrings.reviews})'));
      await tester.pumpAndSettle();

      // Assert
      expect(navigatedToReviews, isTrue);
      expect(find.text('Reviews View Screen'), findsOneWidget);
    });
  });
}
