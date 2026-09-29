import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/helpers/validator.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_keyboard_unfocus.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signin_cubit/sign_in_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/social_sign_in_cubit/social_sign_in_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/auth_header_section.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/auth_redirect_text.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/social_auth_section.dart';
import 'package:gap/gap.dart';
import 'package:toastification/toastification.dart';

import '../args/login_args.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, this.loginArgs});

  final LoginArgs? loginArgs;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _formKey = GlobalKey<FormState>();
    setState(() {});
  }

  Future<void> _navigate({
    required BuildContext context,
    required String routeName,
  }) async {
    final result = await context.pushNamed(routeName);
    if (result != null && result is LoginArgs) {
      _emailController.text = result.email;
      _passwordController.text = result.password;
    } else {
      _clearForm();
    }
  }

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController(
      text: widget.loginArgs?.email ?? '',
    );
    _passwordController = TextEditingController(
      text: widget.loginArgs?.password ?? '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => getIt.get<SignInCubit>()),
      BlocProvider(create: (context) => getIt.get<SocialSignInCubit>()),
    ],
    child: Scaffold(
      appBar: CustomAppBar(title: AppStrings.login, showArrowBack: false),
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
                  child: AuthHeaderSection(
                    imagePath: AppAssets.imagesAppLogo,
                    title: AppStrings.welcome,
                    subtitle: AppStrings.appTagline,
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
                        action: TextInputAction.next,
                      ),
                      Gap(16.h),
                      TextFormFieldHelper(
                        controller: _passwordController,
                        hint: AppStrings.password,
                        isPassword: true,
                        keyboardType: TextInputType.visiblePassword,
                        onValidate: Validator.validatePassword,
                        action: TextInputAction.done,
                      ),
                      Gap(16.h),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: GestureDetector(
                          onTap: () async => await _navigate(
                            context: context,
                            routeName: Routes.forgetPasswordView,
                          ),
                          child: Text(
                            AppStrings.forgotPassword,
                            style: AppTextStyles.font13SemiBold.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                      ),
                      Gap(28.h),
                      BlocConsumer<SignInCubit, SignInState>(
                        listener: (context, state) {
                          if (state is SignInSuccess) {
                            AppToast.show(
                              context: context,
                              title: AppStrings.welcome,
                              type: ToastificationType.success,
                            );
                            context.pushReplacementNamed(Routes.mainView);
                          }
                          if (state is SignInFailure) {
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
                              context
                                  .read<SignInCubit>()
                                  .signInWithEmailAndPassword(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  );
                            }
                          },
                          maxWidth: true,
                          text: AppStrings.login,
                          textStyle: AppTextStyles.font16Bold.copyWith(
                            color: AppPalette.white,
                          ),
                          isLoading: state is SignInLoading,
                        ),
                      ),
                      Gap(28.h),
                      AuthRedirectText(
                        question: AppStrings.dontHaveAccount,
                        action: AppStrings.createAnAccount,
                        onTap: () async => await _navigate(
                          context: context,
                          routeName: Routes.registerView,
                        ),
                      ),
                      Gap(28.h),
                      const SocialAuthSection(),
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
