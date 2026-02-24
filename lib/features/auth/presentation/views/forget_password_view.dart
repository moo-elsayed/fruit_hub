import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/auth/presentation/managers/forget_password_cubit/forget_password_cubit.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:gap/gap.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/helpers/validator.dart';
import '../../../../core/widgets/app_toasts.dart';
import '../../../../core/widgets/custom_material_button.dart';
import '../../../../core/widgets/text_form_field_helper.dart';
import '../../domain/use_cases/forget_password_use_case.dart';
import '../args/login_args.dart';
import '../widgets/custom_dialog.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "password_reset".tr(),
        showArrowBack: true,
        onTap: () => context.pop(),
      ),
      body: BlocProvider(
        create: (context) =>
            ForgetPasswordCubit(getIt.get<ForgetPasswordUseCase>()),
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Gap(24.h),
                  Text(
                    "send_email_reset_link".tr(),
                    style: AppTextStyles.font16color616A6BSemiBold,
                  ),
                  Gap(30.h),
                  TextFormFieldHelper(
                    controller: _emailController,
                    hint: "email".tr(),
                    keyboardType: TextInputType.emailAddress,
                    onValidate: Validator.validateEmail,
                    action: TextInputAction.done,
                  ),
                  Gap(16.h),
                  BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
                    listener: (context, state) {
                      if (state is ForgetPasswordSuccess) {
                        AppToast.showToast(
                          context: context,
                          title: "email_sent".tr(),
                          type: ToastificationType.success,
                        );
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CustomDialog(
                            text: "email_sent_to_reset".tr(),
                            onPressed: () {
                              context.pop();
                              var loginArgs = LoginArgs(
                                email: _emailController.text.trim(),
                                password: "",
                              );
                              context.pop(loginArgs);
                            },
                          ),
                        );
                      }
                      if (state is ForgetPasswordFailure) {
                        AppToast.showToast(
                          context: context,
                          title: state.errorMessage,
                          type: ToastificationType.error,
                        );
                      }
                    },
                    builder: (context, state) {
                      return CustomMaterialButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<ForgetPasswordCubit>().forgetPassword(
                              _emailController.text,
                            );
                          }
                        },
                        maxWidth: true,
                        text: "send_password_reset_link".tr(),
                        textStyle: AppTextStyles.font16WhiteBold,
                        isLoading: state is ForgetPasswordLoading,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
