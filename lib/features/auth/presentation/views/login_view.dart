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
import 'package:fruit_hub/features/auth/presentation/widgets/auth_redirect_text.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/custom_app_bar.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/forget_password.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/or_divider.dart';
import 'package:fruit_hub/generated/assets.dart';
import 'package:gap/gap.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/custom_material_button.dart';
import '../managers/signin_cubit/sign_in_cubit.dart';
import '../widgets/social_login_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SignInCubit(getIt.get<SignInWithEmailAndPasswordUseCase>()),
      child: Scaffold(
        appBar: CustomAppBar(title: "login".tr()),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Gap(24.h),
                  TextFormFieldHelper(
                    hint: "email".tr(),
                    keyboardType: TextInputType.emailAddress,
                    onValidate: Validator.validateEmail,
                    action: TextInputAction.next,
                  ),
                  Gap(16.h),
                  TextFormFieldHelper(
                    hint: "password".tr(),
                    isPassword: true,
                    obscuringCharacter: '●',
                    keyboardType: TextInputType.visiblePassword,
                    onValidate: Validator.validatePassword,
                    action: TextInputAction.done,
                  ),
                  Gap(16.h),
                  ForgetPassword(onTap: () {}),
                  Gap(33.h),
                  CustomMaterialButton(
                    onPressed: () {},
                    maxWidth: true,
                    text: "login".tr(),
                    textStyle: AppTextStyles.font16WhiteBold,
                  ),
                  Gap(33.h),
                  AuthRedirectText(
                    question: "don't_have_account".tr(),
                    action: "create_an_account".tr(),
                    onTap: () => context.pushNamed(Routes.registerView),
                  ),
                  Gap(33.h),
                  const OrDivider(),
                  Gap(16.h),
                  SocialLoginButton(
                    onPressed: () {},
                    text: "sign_in_with_google".tr(),
                    socialIcon: SvgPicture.asset(Assets.iconsGoogleIcon),
                  ),
                  Gap(16.h),
                  SocialLoginButton(
                    onPressed: () {},
                    text: "sign_in_with_apple".tr(),
                    socialIcon: SvgPicture.asset(Assets.iconsAppleIcon),
                  ),
                  Gap(16.h),
                  SocialLoginButton(
                    onPressed: () {},
                    text: "sign_in_with_facebook".tr(),
                    socialIcon: SvgPicture.asset(Assets.iconsFacebookIcon),
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
