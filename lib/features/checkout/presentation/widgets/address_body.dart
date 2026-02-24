import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
        child: Form(
          key: widget.addressArgs.formKey,
          child: Column(
            children: [
              Gap(2.h),
              TextFormFieldHelper(
                controller: widget.addressArgs.nameController,
                labelText: "full_name".tr(),
                keyboardType: TextInputType.name,
                onValidate: Validator.validateName,
                action: TextInputAction.next,
              ),
              Gap(16.h),
              TextFormFieldHelper(
                controller: widget.addressArgs.emailController,
                labelText: "email".tr(),
                keyboardType: TextInputType.emailAddress,
                onValidate: Validator.validateEmail,
                action: TextInputAction.next,
              ),
              Gap(16.h),
              TextFormFieldHelper(
                controller: widget.addressArgs.phoneController,
                labelText: "phone_number".tr(),
                keyboardType: TextInputType.phone,
                onValidate: Validator.validatePhoneNumber,
                action: TextInputAction.next,
              ),
              Gap(16.h),
              TextFormFieldHelper(
                controller: widget.addressArgs.cityController,
                labelText: "city".tr(),
                keyboardType: TextInputType.streetAddress,
                onValidate: Validator.validateCity,
                action: TextInputAction.done,
              ),
              Gap(16.h),
              TextFormFieldHelper(
                controller: widget.addressArgs.streetNameController,
                labelText: "street_name".tr(),
                keyboardType: TextInputType.streetAddress,
                onValidate: Validator.validateStreetName,
                action: TextInputAction.next,
              ),
              Gap(16.h),
              TextFormFieldHelper(
                controller: widget.addressArgs.buildingController,
                labelText: "building_number".tr(),
                keyboardType: TextInputType.number,
                onValidate: Validator.validateBuildingNumber,
                action: TextInputAction.next,
              ),
              Gap(16.h),
              Row(
                spacing: 8.w,
                crossAxisAlignment: .start,
                children: [
                  Expanded(
                    child: TextFormFieldHelper(
                      controller: widget.addressArgs.floorController,
                      labelText: "floor_number".tr(),
                      keyboardType: TextInputType.number,
                      onValidate: Validator.validateFloorNumber,
                      action: TextInputAction.done,
                    ),
                  ),
                  Expanded(
                    child: TextFormFieldHelper(
                      controller: widget.addressArgs.apartmentController,
                      labelText: "apartment_number".tr(),
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
}
