import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/services/location/location_service.dart';
import 'package:fruit_hub/core/widgets/custom_arrow_back.dart';
import 'package:fruit_hub/features/checkout/presentation/views/location_picker_view.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/location_picker_bottom_sheet.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/map_locate_me_button.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/map_pin_indicator.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_widget_wrapper.dart';

class MockLocationService extends Mock implements LocationService {}

void main() {
  late MockLocationService mockLocationService;

  void setupGoogleMapsMock() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.dev/google_maps_android'),
          (MethodCall call) async => null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.dev/google_maps_ios'),
          (MethodCall call) async => null,
        );
  }

  setUp(() {
    mockLocationService = MockLocationService();

    if (getIt.isRegistered<LocationService>()) {
      getIt.unregister<LocationService>();
    }
    getIt.registerLazySingleton<LocationService>(() => mockLocationService);

    // Stub both methods to avoid null errors
    when(
      () => mockLocationService.getAreaName(
        any(),
        any(),
        localeIdentifier: any(named: 'localeIdentifier'),
      ),
    ).thenAnswer((_) async => 'Cairo');

    setupGoogleMapsMock();
  });

  tearDown(() {
    if (getIt.isRegistered<LocationService>()) {
      getIt.unregister<LocationService>();
    }
  });

  void setWindowSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('LocationPickerView Widget Tests', () {
    testWidgets(
      'should render CustomArrowBack, MapPinIndicator, MapLocateMeButton, and LocationPickerBottomSheet',
      (tester) async {
        // Arrange
        setWindowSize(tester);

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(child: const LocationPickerView()),
        );
        await tester.pump();

        // Assert
        expect(find.byType(CustomArrowBack), findsOneWidget);
        expect(find.byType(MapPinIndicator), findsOneWidget);
        expect(find.byType(MapLocateMeButton), findsOneWidget);
        expect(find.byType(LocationPickerBottomSheet), findsOneWidget);
      },
    );

    testWidgets(
      'should not call determinePosition when initialLatitude and initialLongitude are provided',
      (tester) async {
        // Arrange
        setWindowSize(tester);

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(
            child: const LocationPickerView(
              initialLatitude: 30.0444,
              initialLongitude: 31.2357,
            ),
          ),
        );
        await tester.pump();

        // Assert — view renders and no determinePosition is called
        expect(find.byType(LocationPickerView), findsOneWidget);
        verifyNever(() => mockLocationService.determinePosition());
      },
    );

    testWidgets(
      'should show loading UI in bottom sheet initially when no coords provided',
      (tester) async {
        // Arrange
        setWindowSize(tester);
        // Use a Completer so determinePosition never resolves → isLoading stays true
        when(() => mockLocationService.determinePosition()).thenAnswer(
          (_) => Completer<dynamic>().future.then((_) => throw Exception()),
        );

        // Act — pump once to build the widget (before postFrameCallback fires)
        await tester.pumpWidget(
          createWidgetForTesting(child: const LocationPickerView()),
        );
        // One pump triggers the frame, initState sets isLoading=true synchronously
        await tester.pump();

        // Assert — bottom sheet is in loading state
        final bottomSheet = tester.widget<LocationPickerBottomSheet>(
          find.byType(LocationPickerBottomSheet),
        );
        expect(bottomSheet.isLoading, isTrue);
        expect(bottomSheet.cityName, isEmpty);
      },
    );

    testWidgets(
      'should clear loading state in bottom sheet when determinePosition throws',
      (tester) async {
        // Arrange
        setWindowSize(tester);
        when(() => mockLocationService.determinePosition())
            .thenThrow(Exception('location unavailable'));

        // Act
        await tester.pumpWidget(
          createWidgetForTesting(child: const LocationPickerView()),
        );
        await tester.pumpAndSettle();

        // Assert — isLoading cleared after the exception
        final bottomSheet = tester.widget<LocationPickerBottomSheet>(
          find.byType(LocationPickerBottomSheet),
        );
        expect(bottomSheet.isLoading, isFalse);
      },
    );
  });
}
