import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/helpers/validator.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_keyboard_unfocus.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/custom_success_dialog.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';
import 'package:fruit_hub/features/auth/presentation/managers/forget_password_cubit/forget_password_cubit.dart';
import 'package:gap/gap.dart';
import 'package:toastification/toastification.dart';

import '../args/login_args.dart';
import '../widgets/auth_header_section.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  late TextEditingController _emailController;
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: AppStrings.passwordReset,
      showArrowBack: true,
      onTap: () => context.pop(),
    ),
    body: BlocProvider(
      create: (context) => getIt.get<ForgetPasswordCubit>(),
      child: CustomKeyboardUnfocus(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Gap(16.h),
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: AuthHeaderSection(
                    icon: Icons.lock_reset_rounded,
                    title: AppStrings.passwordReset,
                    subtitle: AppStrings.sendEmailResetLink,
                  ),
                ),
                Gap(32.h),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      TextFormFieldHelper(
                        controller: _emailController,
                        hint: AppStrings.email,
                        keyboardType: TextInputType.emailAddress,
                        onValidate: Validator.validateEmail,
                        action: TextInputAction.done,
                      ),
                      Gap(28.h),
                      BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
                        listener: (context, state) {
                          if (state is ForgetPasswordSuccess) {
                            AppToast.show(
                              context: context,
                              title: AppStrings.emailSent,
                              type: ToastificationType.success,
                            );
                            CustomSuccessDialog.show(
                              context: context,
                              text: AppStrings.emailSentToReset,
                              onPressed: () {
                                context.pop();
                                final loginArgs = LoginArgs(
                                  email: _emailController.text.trim(),
                                  password: '',
                                );
                                context.pop(loginArgs);
                              },
                            );
                          }
                          if (state is ForgetPasswordFailure) {
                            AppToast.show(
                              context: context,
                              title: state.errorMessage,
                              type: ToastificationType.error,
                            );
                          }
                        },
                        builder: (context, state) => CustomMaterialButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context
                                  .read<ForgetPasswordCubit>()
                                  .forgetPassword(_emailController.text.trim());
                            }
                          },
                          maxWidth: true,
                          text: AppStrings.sendPasswordResetLink,
                          textStyle: AppTextStyles.font16Bold.copyWith(
                            color: AppPalette.white,
                          ),
                          isLoading: state is ForgetPasswordLoading,
                        ),
                      ),
                      Gap(24.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
