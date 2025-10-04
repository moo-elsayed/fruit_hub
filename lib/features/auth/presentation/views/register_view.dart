import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/dependency_injection.dart';
import 'package:fruit_hub/core/helpers/extentions.dart';
import 'package:fruit_hub/core/helpers/validator.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/create_user_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/terms_and_conditions.dart';
import 'package:gap/gap.dart';
import 'package:toastification/toastification.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_material_button.dart';
import '../../../../core/widgets/text_form_field_helper.dart';
import '../args/login_args.dart';
import '../managers/signup_cubit/sign_up_cubit.dart';
import '../widgets/auth_redirect_text.dart';
import '../widgets/custom_app_bar.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SignupCubit(getIt.get<CreateUserWithEmailAndPasswordUseCase>()),
      child: Scaffold(
        appBar: CustomAppBar(
          title: "new_account".tr(),
          showArrowBack: true,
          onTap: () => context.pop(),
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Gap(24.h),
                    TextFormFieldHelper(
                      controller: _nameController,
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
                      controller: _passwordController,
                      hint: "password".tr(),
                      isPassword: true,
                      obscuringCharacter: '●',
                      keyboardType: TextInputType.visiblePassword,
                      onValidate: Validator.validatePassword,
                      action: TextInputAction.done,
                    ),
                    Gap(16.h),
                    TermsAndConditions(
                      onChanged: (value) => _agreeToTerms = value,
                    ),
                    Gap(30.h),
                    BlocConsumer<SignupCubit, SignupState>(
                      listener: (context, state) {
                        if (state is SignUpSuccess) {
                          AppToast.showToast(
                            context: context,
                            title: "email_created".tr(),
                            type: ToastificationType.success,
                          );
                          var loginArgs = LoginArgs(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                          context.pop(loginArgs);
                        }
                        if (state is SignUpFailure) {
                          AppToast.showToast(
                            context: context,
                            title: state.message,
                            type: ToastificationType.error,
                          );
                        }
                      },
                      builder: (context, state) {
                        return CustomMaterialButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                _agreeToTerms) {
                              context
                                  .read<SignupCubit>()
                                  .createUserWithEmailAndPassword(
                                    username: _nameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                            }
                            if (!_agreeToTerms) {
                              AppToast.showToast(
                                context: context,
                                title: "you_should_accept_terms_and_conditions"
                                    .tr(),
                                type: ToastificationType.error,
                              );
                            }
                          },
                          maxWidth: true,
                          isLoading: state is SignUpLoading,
                          text: "login".tr(),
                          textStyle: AppTextStyles.font16WhiteBold,
                        );
                      },
                    ),
                    Gap(33.h),
                    AuthRedirectText(
                      question: "already_have_an_account".tr(),
                      action: "login".tr(),
                      onTap: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
