import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/address_review_content.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  group('AddressReviewContent Widget Tests', () {
    testWidgets(
      'should render name, separator, phone, and formatted location when all details are provided',
      (tester) async {
        // Arrange
        const address = AddressEntity(
          name: 'أحمد محمود',
          phone: '01012345678',
          city: 'القاهرة',
          streetName: 'شارع التحرير',
          buildingNumber: '5',
          floorNumber: '3',
          apartmentNumber: '12',
        );

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const AddressReviewContent(address: address),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('أحمد محمود'), findsOneWidget);
        expect(find.text(' • '), findsOneWidget);
        expect(find.text('01012345678'), findsOneWidget);
        expect(find.text(address.formattedLocation), findsOneWidget);
      },
    );

    testWidgets(
      'should render only phone and location without separator when name is empty',
      (tester) async {
        // Arrange
        const address = AddressEntity(
          name: '',
          phone: '01012345678',
          city: 'الجيزة',
          streetName: 'شارع الهرم',
        );

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const AddressReviewContent(address: address),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(' • '), findsNothing);
        expect(find.text('01012345678'), findsOneWidget);
        expect(find.text(address.formattedLocation), findsOneWidget);
      },
    );

    testWidgets(
      'should render only location when both name and phone are empty',
      (tester) async {
        // Arrange
        const address = AddressEntity(
          name: '',
          phone: '',
          city: 'الإسكندرية',
          streetName: 'طريق الكورنيش',
        );

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const AddressReviewContent(address: address),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(' • '), findsNothing);
        expect(find.text(address.formattedLocation), findsOneWidget);
      },
    );
  });
}
