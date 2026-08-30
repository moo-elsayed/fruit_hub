import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/features/checkout/presentation/args/address_args.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/save_address.dart';
import 'package:gap/gap.dart';
import '../../../../core/helpers/validator.dart';
import '../../../../core/widgets/text_form_field_helper.dart';

class AddressBody extends StatefulWidget {
  const AddressBody({super.key, required this.addressArgs});

  final AddressArgs addressArgs;

  @override
  State<AddressBody> createState() => _AddressBodyState();
}

class _AddressBodyState extends State<AddressBody> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<CheckoutCubit>();
    if (cubit.address != null) {
      widget.addressArgs.setValues(cubit.address!);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 4.w),
    child: SingleChildScrollView(
      child: Form(
        key: widget.addressArgs.formKey,
        child: Column(
          children: [
            Gap(2.h),
            TextFormFieldHelper(
              controller: widget.addressArgs.nameController,
              labelText: AppStrings.fullName,
              keyboardType: TextInputType.name,
              onValidate: Validator.validateName,
              action: TextInputAction.next,
            ),
            Gap(16.h),
            TextFormFieldHelper(
              controller: widget.addressArgs.emailController,
              labelText: AppStrings.email,
              keyboardType: TextInputType.emailAddress,
              onValidate: Validator.validateEmail,
              action: TextInputAction.next,
            ),
            Gap(16.h),
            TextFormFieldHelper(
              controller: widget.addressArgs.phoneController,
              labelText: AppStrings.phoneNumber,
              keyboardType: TextInputType.phone,
              onValidate: Validator.validatePhoneNumber,
              action: TextInputAction.next,
            ),
            Gap(16.h),
            TextFormFieldHelper(
              controller: widget.addressArgs.cityController,
              labelText: AppStrings.city,
              keyboardType: TextInputType.streetAddress,
              onValidate: Validator.validateCity,
              action: TextInputAction.done,
            ),
            Gap(16.h),
            TextFormFieldHelper(
              controller: widget.addressArgs.streetNameController,
              labelText: AppStrings.streetName,
              keyboardType: TextInputType.streetAddress,
              onValidate: Validator.validateStreetName,
              action: TextInputAction.next,
            ),
            Gap(16.h),
            TextFormFieldHelper(
              controller: widget.addressArgs.buildingController,
              labelText: AppStrings.buildingNumber,
              keyboardType: TextInputType.number,
              onValidate: Validator.validateBuildingNumber,
              action: TextInputAction.next,
            ),
            Gap(16.h),
            Row(
              spacing: 8.w,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormFieldHelper(
                    controller: widget.addressArgs.floorController,
                    labelText: AppStrings.floorNumber,
                    keyboardType: TextInputType.number,
                    onValidate: Validator.validateFloorNumber,
                    action: TextInputAction.done,
                  ),
                ),
                Expanded(
                  child: TextFormFieldHelper(
                    controller: widget.addressArgs.apartmentController,
                    labelText: AppStrings.apartmentNumber,
                    keyboardType: TextInputType.number,
                    onValidate: Validator.validateApartmentNumber,
                    action: TextInputAction.done,
                  ),
                ),
              ],
            ),
            Gap(16.h),
            SaveAddress(
              value: true,
              onChanged: (value) =>
                  context.read<CheckoutCubit>().setSaveAddress(value),
            ),
            Gap(16.h),
          ],
        ),
      ),
    ),
  );
}
