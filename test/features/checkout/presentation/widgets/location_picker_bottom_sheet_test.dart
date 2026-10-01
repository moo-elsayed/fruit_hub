import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/location_picker_bottom_sheet.dart';

import '../../../../helpers/test_widget_wrapper.dart';

void main() {
  void setWindowSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildTestWidget({
    String cityName = '',
    bool isLoading = false,
    VoidCallback? onConfirm,
  }) => createWidgetForTesting(
    child: Stack(
      children: [
        LocationPickerBottomSheet(
          cityName: cityName,
          isLoading: isLoading,
          onConfirm: onConfirm ?? () {},
        ),
      ],
    ),
  );

  group('LocationPickerBottomSheet Widget Tests', () {
    testWidgets(
      'should show loading indicator and locating text when isLoading is true',
      (tester) async {
        // Arrange
        setWindowSize(tester);

        // Act
        await tester.pumpWidget(buildTestWidget(isLoading: true));
        await tester.pump();

        // Assert — one inside the address row, one inside the loading button
        expect(find.byType(CupertinoActivityIndicator), findsNWidgets(2));
        expect(find.text(AppStrings.locating), findsOneWidget);
      },
    );

    testWidgets(
      'should show city name when isLoading is false and cityName is provided',
      (tester) async {
        // Arrange
        setWindowSize(tester);
        const tCity = 'Cairo';

        // Act
        await tester.pumpWidget(
          buildTestWidget(cityName: tCity, isLoading: false),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(tCity), findsOneWidget);
        expect(find.byType(CupertinoActivityIndicator), findsNothing);
      },
    );

    testWidgets(
      'should show drag map hint when isLoading is false and cityName is empty',
      (tester) async {
        // Arrange
        setWindowSize(tester);

        // Act
        await tester.pumpWidget(
          buildTestWidget(cityName: '', isLoading: false),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(AppStrings.dragMapToSelectLocation), findsOneWidget);
      },
    );

    testWidgets('should render selectedLocation label', (tester) async {
      // Arrange
      setWindowSize(tester);

      // Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(AppStrings.selectedLocation), findsOneWidget);
    });

    testWidgets('should render confirm button with confirmLocation text', (
      tester,
    ) async {
      // Arrange
      setWindowSize(tester);

      // Act
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CustomMaterialButton), findsOneWidget);
      expect(find.text(AppStrings.confirmLocation), findsOneWidget);
    });

    testWidgets('should invoke onConfirm when confirm button is tapped', (
      tester,
    ) async {
      // Arrange
      setWindowSize(tester);
      bool confirmed = false;
      await tester.pumpWidget(
        buildTestWidget(
          cityName: 'Giza',
          isLoading: false,
          onConfirm: () => confirmed = true,
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text(AppStrings.confirmLocation));
      await tester.pumpAndSettle();

      // Assert
      expect(confirmed, isTrue);
    });
  });
}
