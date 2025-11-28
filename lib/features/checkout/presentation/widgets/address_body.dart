import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/save_address.dart';
import 'package:gap/gap.dart';
import '../../../../core/helpers/validator.dart';
import '../../../../core/widgets/text_form_field_helper.dart';

class AddressBody extends StatefulWidget {
  const AddressBody({super.key});

  @override
  State<AddressBody> createState() => _AddressBodyState();
}

class _AddressBodyState extends State<AddressBody> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _floorNumberController;
  late TextEditingController _apartmentNumberController;
  bool _saveAddress = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _floorNumberController = TextEditingController();
    _apartmentNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _floorNumberController.dispose();
    _apartmentNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormFieldHelper(
                controller: _fullNameController,
                hint: "full_name".tr(),
                keyboardType: TextInputType.name,
                onValidate: Validator.validateName,
                action: TextInputAction.next,
              ),
              Gap(16.h),
              TextFormFieldHelper(
                controller: _emailController,
                hint: "email".tr(),
                keyboardType: TextInputType.emailAddress,
                onValidate: Validator.validateEmail,
                action: TextInputAction.next,
              ),
              Gap(16.h),
              TextFormFieldHelper(
                controller: _phoneNumberController,
                hint: "phone_number".tr(),
                keyboardType: TextInputType.phone,
                onValidate: Validator.validatePhoneNumber,
                action: TextInputAction.next,
              ),
              Gap(16.h),
              TextFormFieldHelper(
                controller: _addressController,
                hint: "address".tr(),
                keyboardType: TextInputType.streetAddress,
                onValidate: Validator.validateAddress,
                action: TextInputAction.next,
              ),
              Gap(16.h),
              TextFormFieldHelper(
                controller: _cityController,
                hint: "city".tr(),
                keyboardType: TextInputType.streetAddress,
                onValidate: Validator.validateAddress,
                action: TextInputAction.done,
              ),
              Gap(16.h),
              Row(
                spacing: 8.w,
                children: [
                  Expanded(
                    child: TextFormFieldHelper(
                      controller: _cityController,
                      hint: "floor_number".tr(),
                      keyboardType: TextInputType.streetAddress,
                      onValidate: Validator.validateFloorNumber,
                      action: TextInputAction.done,
                    ),
                  ),
                  Expanded(
                    child: TextFormFieldHelper(
                      controller: _cityController,
                      hint: "apartment_number".tr(),
                      keyboardType: TextInputType.streetAddress,
                      onValidate: Validator.validateApartmentNumber,
                      action: TextInputAction.done,
                    ),
                  ),
                ],
              ),
              Gap(16.h),
              SaveAddress(onChanged: (value) => _saveAddress = value),
              Gap(16.h),
            ],
          ),
        ),
      ),
    );
  }
}
