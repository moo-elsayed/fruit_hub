import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/address_review_card.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/address_review_content.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('AddressReviewCard Widget Tests', () {
    testWidgets(
      'should render AddressReviewContent and location SVG when address is provided',
      (tester) async {
        // Arrange
        const address = AddressEntity(
          name: 'محمد خالد',
          phone: '01122334455',
          city: 'القاهرة',
          streetName: 'شارع المعز',
        );

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const AddressReviewCard(address: address),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AddressReviewContent), findsOneWidget);
        expect(find.byType(SvgPicture), findsOneWidget);
        expect(find.text('محمد خالد'), findsOneWidget);
      },
    );

    testWidgets(
      'should render SizedBox.shrink without AddressReviewContent when address is null',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createWidgetForTesting(child: const AddressReviewCard(address: null)),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AddressReviewContent), findsNothing);
        expect(find.byType(SvgPicture), findsOneWidget);
      },
    );
  });
}
