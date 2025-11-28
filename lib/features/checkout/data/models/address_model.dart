import '../../domain/entities/address_entity.dart';

class AddressModel {
  AddressModel({
    required this.address,
    required this.floorNumber,
    required this.apartmentNumber,
    required this.phone,
    required this.city,
  });

  final String phone;
  final String address;
  final String city;
  final String floorNumber;
  final String apartmentNumber;

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'street': address,
      'city': city,
      'floor_number': floorNumber,
      'apartment_number': apartmentNumber,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> map) {
    return AddressModel(
      phone: map['phone'] ?? '',
      address: map['street'] ?? '',
      city: map['city'] ?? '',
      floorNumber: map['floor_number'] ?? '',
      apartmentNumber: map['apartment_number'] ?? '',
    );
  }

  factory AddressModel.fromEntity(AddressEntity entity) => AddressModel(
    address: entity.street,
    floorNumber: entity.floor,
    apartmentNumber: entity.apartment,
    phone: entity.phone,
    city: entity.city,
  );

  AddressEntity toEntity() {
    return AddressEntity(
      street: address,
      floor: floorNumber,
      apartment: apartmentNumber,
      phone: phone,
      city: city,
    );
  }
}
