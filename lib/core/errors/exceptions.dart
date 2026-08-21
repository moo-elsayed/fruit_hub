class BusinessException implements Exception {
  BusinessException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LocationServiceDisabledException implements Exception {
  const LocationServiceDisabledException(this.message);

  final String message;
}

class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException(this.message);

  final String message;
}

class LocationPermissionDeniedForeverException implements Exception {
  const LocationPermissionDeniedForeverException(this.message);

  final String message;
}
