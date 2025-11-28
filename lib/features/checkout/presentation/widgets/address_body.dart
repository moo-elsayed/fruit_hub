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

class AddressBody extends StatelessWidget {
  const AddressBody({super.key, required this.addressArgs});

  final AddressArgs addressArgs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
        child: Form(
          key: addressArgs.formKey,
          child: Column(
            children: [
              TextFormFieldHelper(
                controller: addressArgs.nameController,
                hint: "full_name".tr(),
                keyboardType: TextInputType.name,
                onValidate: Validator.validateName,
                action: TextInputAction.next,
              ),
              Gap(16.h),
              TextFormFieldHelper(
                controller: addressArgs.emailController,
                hint: "email".tr(),
                keyboardType: TextInputType.emailAddress,
                onValidate: Validator.validateEmail,
                action: TextInputAction.next,
              ),
              Gap(16.h),
              TextFormFieldHelper(
                controller: addressArgs.phoneController,
                hint: "phone_number".tr(),
                keyboardType: TextInputType.phone,
                onValidate: Validator.validatePhoneNumber,
                action: TextInputAction.next,
              ),
              Gap(16.h),
              TextFormFieldHelper(
                controller: addressArgs.addressController,
                hint: "address".tr(),
                keyboardType: TextInputType.streetAddress,
                onValidate: Validator.validateAddress,
                action: TextInputAction.next,
              ),
              Gap(16.h),
              TextFormFieldHelper(
                controller: addressArgs.cityController,
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
                      controller: addressArgs.cityController,
                      hint: "floor_number".tr(),
                      keyboardType: TextInputType.streetAddress,
                      onValidate: Validator.validateFloorNumber,
                      action: TextInputAction.done,
                    ),
                  ),
                  Expanded(
                    child: TextFormFieldHelper(
                      controller: addressArgs.cityController,
                      hint: "apartment_number".tr(),
                      keyboardType: TextInputType.streetAddress,
                      onValidate: Validator.validateApartmentNumber,
                      action: TextInputAction.done,
                    ),
                  ),
                ],
              ),
              Gap(16.h),
              SaveAddress(
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
