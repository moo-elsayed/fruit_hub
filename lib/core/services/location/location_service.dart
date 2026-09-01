import 'dart:ui';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart'
    hide LocationServiceDisabledException;

class LocationService {
  LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  void changeSettings({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 0,
  }) => _locationSettings = LocationSettings(
    accuracy: accuracy,
    distanceFilter: distanceFilter,
  );

  Future<Position> determinePosition({LocationSettings? customSettings}) async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException(AppStrings.gpsDisabled);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationPermissionDeniedException(
          AppStrings.locationPermissionDenied,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionDeniedForeverException(
        AppStrings.locationPermissionPermanentlyDenied,
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: customSettings ?? _locationSettings,
    );
  }

  Future<String> getAreaName(
    double latitude,
    double longitude, {
    String? localeIdentifier,
  }) async {
    try {
      final List<Placemark> placemarks = await Geocoding()
          .placemarkFromCoordinates(
            latitude,
            longitude,
            locale: localeIdentifier != null ? Locale(localeIdentifier) : null,
          );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final List<String?> possibleNames = [
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.subLocality,
        ];

        for (final name in possibleNames) {
          if (name != null && name.trim().isNotEmpty && !name.contains('+')) {
            return name.trim();
          }
        }
      }

      return '';
    } catch (_) {
      return '';
    }
  }

  Future<bool> openLocationSettings() async =>
      await Geolocator.openLocationSettings();

  Future<bool> openAppSettings() async => await Geolocator.openAppSettings();
}
