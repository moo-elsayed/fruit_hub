import 'package:flutter/material.dart';
import '../../domain/entities/address_entity.dart';

class AddressArgs {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();

  bool get isValid => formKey.currentState!.validate();

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    floorController.dispose();
    apartmentController.dispose();
  }

  void setValues(AddressEntity address) {
    nameController.text = address.name;
    emailController.text = address.email;
    phoneController.text = address.phone;
    addressController.text = address.address;
    cityController.text = address.city;
    floorController.text = address.floorNumber;
    apartmentController.text = address.apartmentNumber;
  }

  AddressEntity toEntity() => AddressEntity(
    name: nameController.text,
    email: emailController.text,
    phone: phoneController.text,
    address: addressController.text,
    city: cityController.text,
    floorNumber: floorController.text,
    apartmentNumber: apartmentController.text,
  );
}
