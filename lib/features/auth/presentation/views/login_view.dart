import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/helpers/dependency_injection.dart';
import 'package:fruit_hub/core/helpers/extentions.dart';
import 'package:fruit_hub/core/helpers/validator.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';
import 'package:fruit_hub/features/auth/domain/use_cases/sign_in_with_email_and_password_use_case.dart';
import 'package:fruit_hub/features/auth/presentation/managers/social_sign_in_cubit/social_sign_in_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/auth_redirect_text.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/custom_app_bar.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/forget_password.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/or_divider.dart';
import 'package:fruit_hub/generated/assets.dart';
import 'package:gap/gap.dart';
import 'package:toastification/toastification.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/app_toasts.dart';
import '../../../../core/widgets/custom_material_button.dart';
import '../../domain/use_cases/facebook_sign_in_use_case.dart';
import '../../domain/use_cases/google_sign_in_use_case.dart';
import '../args/login_args.dart';
import '../managers/signin_cubit/sign_in_cubit.dart';
import '../widgets/social_login_button.dart';

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
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              SignInCubit(getIt.get<SignInWithEmailAndPasswordUseCase>()),
        ),
        BlocProvider(
          create: (context) => SocialSignInCubit(
            getIt.get<GoogleSignInUseCase>(),
            getIt.get<FacebookSignInUseCase>(),
          ),
        ),
      ],
      child: Scaffold(
        appBar: CustomAppBar(title: "login".tr()),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Gap(24.h),
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
                  ForgetPassword(
                    onTap: () async => await _navigate(
                      context: context,
                      routeName: Routes.forgetPasswordView,
                    ),
                  ),
                  Gap(33.h),
                  BlocConsumer<SignInCubit, SignInState>(
                    listener: (context, state) {
                      if (state is SignInSuccess) {
                        AppToast.showToast(
                          context: context,
                          title: "welcome".tr(),
                          type: ToastificationType.success,
                        );
                      }
                      if (state is SignInFailure) {
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
                          if (_formKey.currentState!.validate()) {
                            context
                                .read<SignInCubit>()
                                .signInWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                          }
                        },
                        maxWidth: true,
                        text: "login".tr(),
                        textStyle: AppTextStyles.font16WhiteBold,
                        isLoading: state is SignInLoading,
                      );
                    },
                  ),
                  Gap(33.h),
                  AuthRedirectText(
                    question: "don't_have_account".tr(),
                    action: "create_an_account".tr(),
                    onTap: () async => await _navigate(
                      context: context,
                      routeName: Routes.registerView,
                    ),
                  ),
                  Gap(33.h),
                  const OrDivider(),
                  Gap(16.h),
                  BlocConsumer<SocialSignInCubit, SocialSignInState>(
                    listener: (context, state) {
                      if (state is GoogleSuccess) {
                        AppToast.showToast(
                          context: context,
                          title: "welcome".tr(),
                          type: ToastificationType.success,
                        );
                      }
                      if (state is GoogleFailure) {
                        AppToast.showToast(
                          context: context,
                          title: state.message,
                          type: ToastificationType.error,
                        );
                      }
                    },
                    buildWhen: (previous, current) =>
                        current is GoogleSuccess ||
                        current is GoogleFailure ||
                        current is GoogleLoading,
                    builder: (context, state) {
                      return SocialLoginButton(
                        onPressed: () =>
                            context.read<SocialSignInCubit>().googleSignIn(),
                        isLoading: state is GoogleLoading,
                        text: "sign_in_with_google".tr(),
                        socialIcon: SvgPicture.asset(Assets.iconsGoogleIcon),
                      );
                    },
                  ),
                  Gap(16.h),
                  if (Platform.isIOS)
                    Column(
                      children: [
                        SocialLoginButton(
                          onPressed: () {},
                          text: "sign_in_with_apple".tr(),
                          socialIcon: SvgPicture.asset(Assets.iconsAppleIcon),
                        ),
                        Gap(16.h),
                      ],
                    ),
                  BlocConsumer<SocialSignInCubit, SocialSignInState>(
                    listener: (context, state) {
                      if (state is FacebookSuccess) {
                        AppToast.showToast(
                          context: context,
                          title: "welcome",
                          type: ToastificationType.success,
                        );
                      }
                      if (state is FacebookFailure) {
                        AppToast.showToast(
                          context: context,
                          title: state.message,
                          type: ToastificationType.error,
                        );
                      }
                    },
                    buildWhen: (previous, current) =>
                        current is FacebookSuccess ||
                        current is FacebookFailure ||
                        current is FacebookLoading,
                    builder: (context, state) {
                      return SocialLoginButton(
                        onPressed: () =>
                            context.read<SocialSignInCubit>().facebookSignIn(),
                        isLoading: state is FacebookLoading,
                        text: "sign_in_with_facebook".tr(),
                        socialIcon: SvgPicture.asset(Assets.iconsFacebookIcon),
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
