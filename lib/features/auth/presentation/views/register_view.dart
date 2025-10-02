import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extentions.dart';
import 'package:fruit_hub/core/helpers/validator.dart';
import 'package:fruit_hub/features/auth/presentation/widgets/terms_and_conditions.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_material_button.dart';
import '../../../../core/widgets/text_form_field_helper.dart';
import '../widgets/auth_redirect_text.dart';
import '../widgets/custom_app_bar.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Column(
              children: [
                Gap(24.h),
                TextFormFieldHelper(
                  hint: "full_name".tr(),
                  keyboardType: TextInputType.name,
                  onValidate: Validator.validateName,
                  action: TextInputAction.next,
                ),
                Gap(16.h),
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
                const TermsAndConditions(),
                Gap(30.h),
                CustomMaterialButton(
                  onPressed: () {},
                  maxWidth: true,
                  text: "login".tr(),
                  textStyle: AppTextStyles.font16WhiteBold,
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
    );
  }
}
