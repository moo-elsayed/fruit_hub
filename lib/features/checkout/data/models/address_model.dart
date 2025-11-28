import '../../domain/entities/address_entity.dart';

class AddressModel {
  AddressModel({
    required this.name,
    required this.email,
    required this.address,
    required this.floorNumber,
    required this.apartmentNumber,
    required this.phone,
    required this.city,
  });

  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String floorNumber;
  final String apartmentNumber;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'street': address,
    'city': city,
    'floor_number': floorNumber,
    'apartment_number': apartmentNumber,
  };

  factory AddressModel.fromJson(Map<String, dynamic> map) => AddressModel(
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    phone: map['phone'] ?? '',
    address: map['street'] ?? '',
    city: map['city'] ?? '',
    floorNumber: map['floor_number'] ?? '',
    apartmentNumber: map['apartment_number'] ?? '',
  );

  factory AddressModel.fromEntity(AddressEntity entity) => AddressModel(
    name: entity.name,
    email: entity.email,
    address: entity.address,
    floorNumber: entity.floorNumber,
    apartmentNumber: entity.apartmentNumber,
    phone: entity.phone,
    city: entity.city,
  );

  AddressEntity toEntity() => AddressEntity(
    name: name,
    email: email,
    address: address,
    floorNumber: floorNumber,
    apartmentNumber: apartmentNumber,
    phone: phone,
    city: city,
  );
}
