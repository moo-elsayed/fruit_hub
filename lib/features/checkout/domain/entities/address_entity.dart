import 'package:equatable/equatable.dart';

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
