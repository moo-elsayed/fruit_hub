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
  });

  final String name;
  final String email;
  final String phone;
  final String city;
  final String streetName;
  final String buildingNumber;
  final String floorNumber;
  final String apartmentNumber;

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
  ];
}
