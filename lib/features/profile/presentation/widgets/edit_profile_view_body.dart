import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/helpers/validator.dart';
import 'package:fruit_hub/core/widgets/custom_keyboard_unfocus.dart';
import 'package:fruit_hub/core/widgets/image_picker_field.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';
import 'package:fruit_hub/features/auth/domain/entities/user_entity.dart';
import 'package:gap/gap.dart';

import '../../domain/entities/update_profile_input_entity.dart';
import '../managers/edit_profile_cubit/edit_profile_cubit.dart';
import 'change_password_tile.dart';
import 'edit_profile_card_container.dart';
import 'edit_profile_header_card.dart';
import 'edit_profile_save_button.dart';
import 'edit_profile_section_header.dart';

class EditProfileViewBody extends StatefulWidget {
  const EditProfileViewBody({super.key});

  @override
  State<EditProfileViewBody> createState() => _EditProfileViewBodyState();
}

class _EditProfileViewBodyState extends State<EditProfileViewBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _imageController;
  UserEntity? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = context.read<EditProfileCubit>().currentUser;
    _nameController = TextEditingController(text: _currentUser?.name ?? '');
    _phoneController = TextEditingController(text: _currentUser?.phone ?? '');
    _emailController = TextEditingController(text: _currentUser?.email ?? '');
    _imageController = TextEditingController(text: _currentUser?.image ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() == true) {
      final user = context.read<EditProfileCubit>().currentUser;
      context.read<EditProfileCubit>().updateProfile(
        UpdateProfileInputEntity(
          uid: user?.uid ?? '',
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          image: _imageController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<EditProfileCubit, EditProfileState>(
        listener: (context, state) {
          if (state is EditProfileSuccess) {
            _imageController.text = state.user.image;
          }
        },
        child: CustomKeyboardUnfocus(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
            EditProfileHeaderCard(imageController: _imageController),
            Gap(24.h),
            EditProfileSectionHeader(
              title: AppStrings.profilePicture,
              icon: Icons.photo_camera_outlined,
            ),
            Gap(10.h),
            ImagePickerField(
              controller: _imageController,
              label: AppStrings.profilePicture,
              icon: Icons.person_outline_rounded,
            ),
            Gap(20.h),
            EditProfileSectionHeader(
              title: AppStrings.basicInfo,
              icon: Icons.person_outline_rounded,
            ),
            Gap(10.h),
            EditProfileCardContainer(
              child: Column(
                children: [
                  TextFormFieldHelper(
                    controller: _nameController,
                    labelText: AppStrings.fullName,
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: context.colors.primary,
                      size: 22.sp,
                    ),
                    onValidate: Validator.validateName,
                  ),
                  Gap(14.h),
                  TextFormFieldHelper(
                    controller: _emailController,
                    labelText: AppStrings.email,
                    enabled: false,
                    fillColor: context.colors.border.withValues(alpha: 0.12),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: context.colors.subText,
                      size: 22.sp,
                    ),
                    suffixWidget: Padding(
                      padding: EdgeInsetsDirectional.only(end: 12.w),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: context.colors.subText,
                        size: 18.sp,
                      ),
                    ),
                  ),
                  Gap(14.h),
                  TextFormFieldHelper(
                    controller: _phoneController,
                    labelText: AppStrings.phoneNumber,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: context.colors.primary,
                      size: 22.sp,
                    ),
                    onValidate: Validator.validatePhoneNumber,
                  ),
                ],
              ),
            ),
            Gap(20.h),
            EditProfileSectionHeader(
              title: AppStrings.accountSecurity,
              icon: Icons.shield_outlined,
            ),
            Gap(10.h),
            const EditProfileCardContainer(child: ChangePasswordTile()),
            Gap(28.h),
            EditProfileSaveButton(onPressed: _onSave),
          ],
        ),
      ),
    ),
  ),
);
}
