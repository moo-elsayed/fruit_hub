import 'package:equatable/equatable.dart';

class SelectedLocationEntity extends Equatable {
  const SelectedLocationEntity({
    required this.latitude,
    required this.longitude,
    this.city = '',
    this.streetName = '',
    this.fullAddress = '',
  });

  final double latitude;
  final double longitude;
  final String city;
  final String streetName;
  final String fullAddress;

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    city,
    streetName,
    fullAddress,
  ];
}
