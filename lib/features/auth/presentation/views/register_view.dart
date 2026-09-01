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
import 'package:gap/gap.dart';
import 'package:toastification/toastification.dart';
import '../../domain/entities/sign_up_input_entity.dart';
import '../args/login_args.dart';
import '../managers/signup_cubit/sign_up_cubit.dart';
import '../widgets/auth_redirect_text.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => getIt.get<SignupCubit>(),
    child: Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.newAccount,
        showArrowBack: true,
        onTap: () => context.pop(),
      ),
      body: CustomKeyboardUnfocus(
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
                  child: Column(
                    children: [
                      Container(
                        width: 72.r,
                        height: 72.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.primary.withValues(alpha: 0.1),
                          border: Border.all(
                            color: context.colors.primary.withValues(
                              alpha: 0.3,
                            ),
                            width: 2.w,
                          ),
                        ),
                        child: Icon(
                          Icons.person_add_rounded,
                          size: 34.sp,
                          color: context.colors.primary,
                        ),
                      ),
                      Gap(16.h),
                      Text(
                        AppStrings.newAccount,
                        style: AppTextStyles.font24Bold.copyWith(
                          color: context.colors.mainText,
                        ),
                      ),
                      Gap(6.h),
                      Text(
                        AppStrings.appTagline,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.font14Regular.copyWith(
                          color: context.colors.subText,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(32.h),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      TextFormFieldHelper(
                        controller: _nameController,
                        hint: AppStrings.fullName,
                        keyboardType: TextInputType.name,
                        onValidate: Validator.validateName,
                        action: TextInputAction.next,
                      ),
                      Gap(16.h),
                      TextFormFieldHelper(
                        controller: _emailController,
                        hint: AppStrings.email,
                        keyboardType: TextInputType.emailAddress,
                        onValidate: Validator.validateEmail,
                        action: TextInputAction.next,
                      ),
                      Gap(16.h),
                      TextFormFieldHelper(
                        controller: _phoneController,
                        hint: AppStrings.phoneNumber,
                        keyboardType: TextInputType.phone,
                        onValidate: Validator.validatePhoneNumber,
                        action: TextInputAction.next,
                      ),
                      Gap(16.h),
                      TextFormFieldHelper(
                        controller: _passwordController,
                        hint: AppStrings.password,
                        isPassword: true,
                        obscuringCharacter: '●',
                        keyboardType: TextInputType.visiblePassword,
                        onValidate: Validator.validatePassword,
                        action: TextInputAction.done,
                      ),
                      Gap(28.h),
                      BlocConsumer<SignupCubit, SignupState>(
                        listener: (context, state) {
                          if (state is SignUpSuccess) {
                            AppToast.show(
                              context: context,
                              title: AppStrings.emailCreated,
                              type: ToastificationType.success,
                            );
                            CustomSuccessDialog.show(
                              context: context,
                              text: AppStrings.emailSentToVerify,
                              onPressed: () {
                                context.pop();
                                final loginArgs = LoginArgs(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );
                                context.pop(loginArgs);
                              },
                            );
                          }
                          if (state is SignUpFailure) {
                            AppToast.show(
                              context: context,
                              title: state.message,
                              type: ToastificationType.error,
                            );
                          }
                        },
                        builder: (context, state) => CustomMaterialButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final input = SignUpInputEntity(
                                username: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                phone: _phoneController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                              context
                                  .read<SignupCubit>()
                                  .createUserWithEmailAndPassword(input);
                            }
                          },
                          maxWidth: true,
                          isLoading: state is SignUpLoading,
                          text: AppStrings.register,
                          textStyle: AppTextStyles.font16Bold.copyWith(
                            color: AppPalette.white,
                          ),
                        ),
                      ),
                      Gap(28.h),
                      AuthRedirectText(
                        question: AppStrings.alreadyHaveAnAccount,
                        action: AppStrings.login,
                        onTap: () => context.pop(),
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
