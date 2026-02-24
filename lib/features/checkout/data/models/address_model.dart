import '../../domain/entities/address_entity.dart';

class AddressModel {
  AddressModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.buildingNumber,
    required this.streetName,
    required this.floorNumber,
    required this.apartmentNumber,
  });

  final String name;
  final String email;
  final String phone;
  final String city;
  final String streetName;
  final String buildingNumber;
  final String floorNumber;
  final String apartmentNumber;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'city': city,
    'street': streetName,
    'building_number': buildingNumber,
    'floor_number': floorNumber,
    'apartment_number': apartmentNumber,
  };

  factory AddressModel.fromJson(Map<String, dynamic> map) => AddressModel(
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    phone: map['phone'] ?? '',
    city: map['city'] ?? '',
    streetName: map['street'] ?? '',
    buildingNumber: map['building_number'] ?? '',
    floorNumber: map['floor_number'] ?? '',
    apartmentNumber: map['apartment_number'] ?? '',
  );

  factory AddressModel.fromEntity(AddressEntity entity) => AddressModel(
    name: entity.name,
    email: entity.email,
    phone: entity.phone,
    city: entity.city,
    streetName: entity.streetName,
    buildingNumber: entity.buildingNumber,
    floorNumber: entity.floorNumber,
    apartmentNumber: entity.apartmentNumber,
  );

  AddressEntity toEntity() => AddressEntity(
    name: name,
    email: email,
    phone: phone,
    city: city,
    streetName: streetName,
    buildingNumber: buildingNumber,
    floorNumber: floorNumber,
    apartmentNumber: apartmentNumber,
  );
}
