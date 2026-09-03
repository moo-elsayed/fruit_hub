import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/services/location/location_service.dart';
import 'package:fruit_hub/core/theming/map_styles.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_arrow_back.dart';
import 'package:fruit_hub/features/checkout/domain/entities/selected_location_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/location_picker_bottom_sheet.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/map_compass_button.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/map_locate_me_button.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/map_pin_indicator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toastification/toastification.dart';

class LocationPickerView extends StatefulWidget {
  const LocationPickerView({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView>
    with WidgetsBindingObserver {
  static const LatLng _cairoDefault = LatLng(30.0444, 31.2357);

  final Completer<GoogleMapController> _controller = Completer();
  late final LocationService _locationService =
      getIt.isRegistered<LocationService>()
      ? getIt.get<LocationService>()
      : LocationService();

  late LatLng _currentPosition;
  double _currentZoom = 15.0;

  final ValueNotifier<double> _bearingNotifier = ValueNotifier(0.0);
  final ValueNotifier<bool> _isMapMovingNotifier = ValueNotifier(false);
  final ValueNotifier<({String city, bool isLoading})> _addressNotifier =
      ValueNotifier((city: '', isLoading: false));

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _currentPosition = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_fetchAddressFromCoordinates(_currentPosition));
      });
    } else {
      _currentPosition = _cairoDefault;
      _addressNotifier.value = (city: '', isLoading: true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_getUserCurrentLocation());
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      unawaited(_getUserCurrentLocation());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bearingNotifier.dispose();
    _isMapMovingNotifier.dispose();
    _addressNotifier.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _getUserCurrentLocation() async {
    _addressNotifier.value = (city: '', isLoading: true);
    try {
      final position = await _locationService.determinePosition();
      _currentPosition = LatLng(position.latitude, position.longitude);

      final GoogleMapController mapController = await _controller.future;
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 16),
        ),
      );

      await _fetchAddressFromCoordinates(_currentPosition);
    } on LocationServiceDisabledException catch (e) {
      _addressNotifier.value = (city: '', isLoading: false);
      if (mounted) {
        AppToast.show(
          context: context,
          title: e.message,
          type: ToastificationType.warning,
        );
      }
    } on LocationPermissionDeniedException catch (e) {
      _addressNotifier.value = (city: '', isLoading: false);
      if (mounted) {
        AppToast.show(
          context: context,
          title: e.message,
          type: ToastificationType.error,
        );
      }
    } on LocationPermissionDeniedForeverException catch (e) {
      _addressNotifier.value = (city: '', isLoading: false);
      if (mounted) {
        AppToast.show(
          context: context,
          title: e.message,
          type: ToastificationType.error,
        );
      }
    } catch (_) {
      _addressNotifier.value = (city: '', isLoading: false);
    }
  }

  Future<void> _fetchAddressFromCoordinates(LatLng position) async {
    _addressNotifier.value = (
      city: _addressNotifier.value.city,
      isLoading: true,
    );
    String? locale;
    try {
      if (mounted) {
        locale = context.locale.languageCode;
      }
    } catch (_) {}

    final area = await _locationService.getAreaName(
      position.latitude,
      position.longitude,
      localeIdentifier: locale,
    );

    if (mounted) {
      _addressNotifier.value = (city: area, isLoading: false);
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentPosition = position.target;
    _currentZoom = position.zoom;
    _bearingNotifier.value = position.bearing;
    if (!_isMapMovingNotifier.value) {
      _isMapMovingNotifier.value = true;
    }
  }

  void _onCameraIdle() {
    _isMapMovingNotifier.value = false;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      unawaited(_fetchAddressFromCoordinates(_currentPosition));
    });
  }

  Future<void> _resetCompass() async {
    final GoogleMapController mapController = await _controller.future;
    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition,
          zoom: _currentZoom,
          bearing: 0.0,
        ),
      ),
    );
  }

  void _handleConfirm() {
    final result = SelectedLocationEntity(
      latitude: _currentPosition.latitude,
      longitude: _currentPosition.longitude,
      city: _addressNotifier.value.city,
      fullAddress: _addressNotifier.value.city,
    );
    context.pop(result);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          style: context.isDarkMode ? MapStyles.dark : null,
          initialCameraPosition: CameraPosition(
            target: _currentPosition,
            zoom: _currentZoom,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          padding: EdgeInsets.only(top: 40.h, bottom: 40.h),
          onMapCreated: (controller) => _controller.complete(controller),
          onCameraMove: _onCameraMove,
          onCameraIdle: _onCameraIdle,
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _isMapMovingNotifier,
          builder: (context, isMoving, _) =>
              MapPinIndicator(isMoving: isMoving),
        ),
        Positioned(
          top: 50.h,
          left: context.isArabic ? null : 20.w,
          right: context.isArabic ? 20.w : null,
          child: const CustomArrowBack(),
        ),
        ValueListenableBuilder<double>(
          valueListenable: _bearingNotifier,
          builder: (context, bearing, _) =>
              MapCompassButton(bearing: bearing, onTap: _resetCompass),
        ),
        MapLocateMeButton(onTap: () => unawaited(_getUserCurrentLocation())),
        ValueListenableBuilder<({String city, bool isLoading})>(
          valueListenable: _addressNotifier,
          builder: (context, state, _) => LocationPickerBottomSheet(
            cityName: state.city,
            isLoading: state.isLoading,
            onConfirm: _handleConfirm,
          ),
        ),
      ],
    ),
  );
}
