import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/features/products/domain/entities/product_details_entity.dart';
import 'package:fruit_hub/features/products/presentation/widgets/product_detail_item.dart';
import 'package:fruit_hub/features/products/presentation/widgets/product_details_grid_view.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  const dummyDetails = [
    ProductDetailsEntity(
      title: '10 أيام',
      subtitle: 'الصلاحية',
      trailingAsset: AppAssets.iconsCalendar,
    ),
    ProductDetailsEntity(
      title: '500 جم',
      subtitle: 'الوزن',
      trailingAsset: AppAssets.iconsScale,
    ),
    ProductDetailsEntity(
      title: '52 سعرة',
      subtitle: 'لكل 100 جم',
      trailingAsset: AppAssets.iconsCalory,
    ),
  ];

  group('ProductDetailsGridView Widget Tests', () {
    testWidgets(
      'should render a ProductDetailItem for each item in productDetails',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const ProductDetailsGridView(productDetails: dummyDetails),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(ProductDetailItem), findsNWidgets(3));
        expect(find.text('10 أيام'), findsOneWidget);
        expect(find.text('500 جم'), findsOneWidget);
        expect(find.text('52 سعرة'), findsOneWidget);
      },
    );
  });
}
