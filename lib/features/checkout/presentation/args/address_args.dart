import 'package:flutter/material.dart';
import '../../domain/entities/address_entity.dart';

class AddressArgs {
  AddressArgs()
    : formKey = GlobalKey<FormState>(),
      nameController = TextEditingController(),
      emailController = TextEditingController(),
      phoneController = TextEditingController(),
      cityController = TextEditingController(),
      streetNameController = TextEditingController(),
      buildingController = TextEditingController(),
      floorController = TextEditingController(),
      apartmentController = TextEditingController();

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController cityController;
  final TextEditingController streetNameController;
  final TextEditingController buildingController;
  final TextEditingController floorController;
  final TextEditingController apartmentController;

  bool get isValid => formKey.currentState!.validate();

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    streetNameController.dispose();
    buildingController.dispose();
    floorController.dispose();
    apartmentController.dispose();
  }

  void setValues(AddressEntity address) {
    nameController.text = address.name;
    emailController.text = address.email;
    phoneController.text = address.phone;
    cityController.text = address.city;
    streetNameController.text = address.streetName;
    buildingController.text = address.buildingNumber;
    floorController.text = address.floorNumber;
    apartmentController.text = address.apartmentNumber;
  }

  AddressEntity toEntity() => AddressEntity(
    name: nameController.text,
    email: emailController.text,
    phone: phoneController.text,
    city: cityController.text,
    streetName: streetNameController.text,
    buildingNumber: buildingController.text,
    floorNumber: floorController.text,
    apartmentNumber: apartmentController.text,
  );
}
