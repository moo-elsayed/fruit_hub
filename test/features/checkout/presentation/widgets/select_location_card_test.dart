import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/features/checkout/domain/entities/selected_location_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/args/address_args.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/select_location_card.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  late AddressArgs addressArgs;

  setUp(() {
    addressArgs = AddressArgs();
  });

  tearDown(() {
    addressArgs.dispose();
  });

  Widget buildTestWidget({SelectedLocationEntity? pickerResult}) =>
      createWidgetForTesting(
        routes: {
          Routes.locationPickerView: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  pickerResult ??
                      const SelectedLocationEntity(
                        latitude: 30.0444,
                        longitude: 31.2357,
                        fullAddress: 'Cairo, Egypt',
                        city: 'القاهرة',
                      ),
                );
              },
              child: const Text('Confirm Location'),
            ),
          ),
        },
        child: SelectLocationCard(addressArgs: addressArgs),
      );

  group('SelectLocationCard Widget Tests', () {
    testWidgets('should render default state when no coordinates are set', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(AppStrings.selectLocationOnMap), findsOneWidget);
      expect(find.text(AppStrings.mapInstructions), findsOneWidget);
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
    });

    testWidgets(
      'should render selected location state when coordinates and city are set',
      (tester) async {
        // Arrange
        addressArgs.setCoordinates(lat: 30.0, lng: 31.0);
        addressArgs.cityController.text = 'مدينة نصر';

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(AppStrings.selectedLocation), findsOneWidget);
        expect(find.text('مدينة نصر'), findsOneWidget);
        expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate to locationPickerView and update addressArgs on result',
      (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Act - Tap on location card to navigate to picker
        await tester.tap(find.byType(SelectLocationCard));
        await tester.pumpAndSettle();

        expect(find.text('Confirm Location'), findsOneWidget);

        // Tap confirm location to return result
        await tester.tap(find.text('Confirm Location'));
        await tester.pumpAndSettle();

        // Assert
        expect(addressArgs.latitude, equals(30.0444));
        expect(addressArgs.longitude, equals(31.2357));
        expect(addressArgs.cityController.text, equals('القاهرة'));
        expect(find.text(AppStrings.selectedLocation), findsOneWidget);
      },
    );
  });
}
