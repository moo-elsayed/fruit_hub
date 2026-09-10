import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/helpers/validator.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_bottom_sheet_handle.dart';
import 'package:fruit_hub/core/widgets/custom_keyboard_unfocus.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';
import 'package:gap/gap.dart';
import 'package:toastification/toastification.dart';

import '../managers/change_password_cubit/change_password_cubit.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => getIt<ChangePasswordCubit>(),
      child: const ChangePasswordBottomSheet(),
    ),
  );

  @override
  State<ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() == true) {
      context.read<ChangePasswordCubit>().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) => CustomKeyboardUnfocus(
    child: Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
          listener: (context, state) {
            if (state is ChangePasswordSuccess) {
              AppToast.show(
                context: context,
                title: AppStrings.passwordChangedSuccessfully,
                type: ToastificationType.success,
              );
              context.pop();
            } else if (state is ChangePasswordFailure) {
              AppToast.show(
                context: context,
                title: state.errorMessage,
                type: ToastificationType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ChangePasswordLoading;

            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomBottomSheetHandle(),
                    Gap(12.h),
                    Text(
                      AppStrings.changePassword,
                      style: AppTextStyles.font18Bold.copyWith(
                        color: context.colors.mainText,
                      ),
                    ),
                    Gap(20.h),
                    TextFormFieldHelper(
                      controller: _currentPasswordController,
                      labelText: AppStrings.currentPassword,
                      isPassword: true,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: context.colors.primary,
                        size: 22.sp,
                      ),
                      action: TextInputAction.next,
                      onValidate: Validator.validateOldPassword,
                    ),
                    Gap(14.h),
                    TextFormFieldHelper(
                      controller: _newPasswordController,
                      labelText: AppStrings.newPassword,
                      isPassword: true,
                      prefixIcon: Icon(
                        Icons.lock_reset_rounded,
                        color: context.colors.primary,
                        size: 22.sp,
                      ),
                      action: TextInputAction.next,
                      onValidate: Validator.validatePassword,
                    ),
                    Gap(14.h),
                    TextFormFieldHelper(
                      controller: _confirmPasswordController,
                      labelText: AppStrings.confirmNewPassword,
                      isPassword: true,
                      prefixIcon: Icon(
                        Icons.check_circle_outline_rounded,
                        color: context.colors.primary,
                        size: 22.sp,
                      ),
                      action: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      onValidate: (value) => Validator.validateConfirmPassword(
                        value,
                        _newPasswordController.text,
                      ),
                    ),
                    Gap(24.h),
                    CustomMaterialButton(
                      maxWidth: true,
                      isLoading: isLoading,
                      onPressed: _submit,
                      text: AppStrings.saveChanges,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    Gap(8.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
