import 'package:flutter/material.dart';
import '../../domain/entities/address_entity.dart';

class AddressArgs {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController streetNameController = TextEditingController();
  final TextEditingController buildingController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();

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
