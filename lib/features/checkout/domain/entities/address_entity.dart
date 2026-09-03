import 'package:equatable/equatable.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';

class AddressEntity extends Equatable {
  const AddressEntity({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.city = '',
    this.streetName = '',
    this.buildingNumber = '',
    this.floorNumber = '',
    this.apartmentNumber = '',
    this.latitude,
    this.longitude,
  });

  final String name;
  final String email;
  final String phone;
  final String city;
  final String streetName;
  final String buildingNumber;
  final String floorNumber;
  final String apartmentNumber;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;

  String get formattedLocation {
    final streetAndCity = [city, streetName]
        .where((s) => s.trim().isNotEmpty)
        .join('، ');

    final buildingParts = <String>[];
    if (buildingNumber.trim().isNotEmpty) {
      buildingParts.add('${AppStrings.building} $buildingNumber');
    }
    if (floorNumber.trim().isNotEmpty) {
      buildingParts.add('${AppStrings.floor} $floorNumber');
    }
    if (apartmentNumber.trim().isNotEmpty) {
      buildingParts.add('${AppStrings.apartment} $apartmentNumber');
    }
    final buildingDetails = buildingParts.join('، ');

    if (streetAndCity.isNotEmpty && buildingDetails.isNotEmpty) {
      return '$streetAndCity\n$buildingDetails';
    }
    return streetAndCity.isNotEmpty ? streetAndCity : buildingDetails;
  }

  AddressEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? city,
    String? streetName,
    String? buildingNumber,
    String? floorNumber,
    String? apartmentNumber,
    double? latitude,
    double? longitude,
  }) => AddressEntity(
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    city: city ?? this.city,
    streetName: streetName ?? this.streetName,
    buildingNumber: buildingNumber ?? this.buildingNumber,
    floorNumber: floorNumber ?? this.floorNumber,
    apartmentNumber: apartmentNumber ?? this.apartmentNumber,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
  );

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    city,
    streetName,
    buildingNumber,
    floorNumber,
    apartmentNumber,
    latitude,
    longitude,
  ];
}
