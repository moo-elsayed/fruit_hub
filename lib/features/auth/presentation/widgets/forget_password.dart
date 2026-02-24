import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theming/app_text_styles.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key, this.onTap});

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          "forgot_password".tr(),
          style: AppTextStyles.font13color2D9F5DSemiBold,
        ),
      ),
    );
  }
}
