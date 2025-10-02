import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/functions.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_material_button.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.socialIcon,
    this.isLoading = false,
    required this.onPressed,
    this.loadingIndicatorColor = AppColors.black,
    required this.text,
  });

  final Widget socialIcon;
  final bool isLoading;
  final void Function() onPressed;
  final Color loadingIndicatorColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        CustomMaterialButton(
          onPressed: onPressed,
          maxWidth: true,
          color: AppColors.white,
          side: const BorderSide(color: AppColors.colorDDDFDF),
          isLoading: isLoading,
          loadingIndicatorColor: loadingIndicatorColor,
          text: text,
          textStyle: AppTextStyles.font16color0C0D0DSemiBold,
        ),
        if (!isLoading)
          Positioned(
            right: isArabic(context) ? 16.w : null,
            left: !isArabic(context) ? 16.w : null,
            child: socialIcon,
          ),
      ],
    );
  }
}
