import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/helpers/extentions.dart';
import 'package:fruit_hub/core/theming/app_colors.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/auth_redirect_text.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/custom_app_bar.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/forget_password.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/or_divider.dart';
import 'package:fruit_hub/generated/assets.dart';
import 'package:gap/gap.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/custom_material_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  action: TextInputAction.next,
                ),
                Gap(16.h),
                TextFormFieldHelper(
                  hint: "password".tr(),
                  isPassword: true,
                  action: TextInputAction.done,
                  obscuringCharacter: '●',
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
                CustomMaterialButton(
                  onPressed: () {},
                  maxWidth: true,
                  color: AppColors.white,
                  side: const BorderSide(color: AppColors.colorDDDFDF),
                  socialLogin: true,
                  socialIcon: SvgPicture.asset(Assets.iconsGoogleIcon),
                  text: "sign_in_with_google".tr(),
                  textStyle: AppTextStyles.font16color0C0D0DSemiBold,
                ),
                Gap(16.h),
                CustomMaterialButton(
                  onPressed: () {},
                  maxWidth: true,
                  color: AppColors.white,
                  side: const BorderSide(color: AppColors.colorDDDFDF),
                  socialLogin: true,
                  socialIcon: SvgPicture.asset(Assets.iconsAppleIcon),
                  text: "sign_in_with_apple".tr(),
                  textStyle: AppTextStyles.font16color0C0D0DSemiBold,
                ),
                Gap(16.h),
                CustomMaterialButton(
                  onPressed: () {},
                  maxWidth: true,
                  color: AppColors.white,
                  side: const BorderSide(color: AppColors.colorDDDFDF),
                  socialLogin: true,
                  socialIcon: SvgPicture.asset(Assets.iconsFacebookIcon),
                  text: "sign_in_with_facebook".tr(),
                  textStyle: AppTextStyles.font16color0C0D0DSemiBold,
                  // isLoading: true,
                  // loadingIndicatorColor: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
