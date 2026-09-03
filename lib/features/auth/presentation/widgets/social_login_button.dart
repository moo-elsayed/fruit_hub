import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/extensions.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_material_button.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.socialIcon,
    this.isLoading = false,
    required this.onPressed,
    this.loadingIndicatorColor,
    required this.text,
  });

  final Widget socialIcon;
  final bool isLoading;
  final VoidCallback onPressed;
  final Color? loadingIndicatorColor;
  final String text;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: AlignmentDirectional.centerStart,
    children: [
      CustomMaterialButton(
        onPressed: onPressed,
        maxWidth: true,
        backgroundColor: context.colors.surface,
        side: BorderSide(color: context.colors.border),
        isLoading: isLoading,
        loadingIndicatorColor: loadingIndicatorColor ?? context.colors.primary,
        text: text,
        textStyle: AppTextStyles.font16SemiBold.copyWith(
          color: context.colors.mainText,
        ),
      ),
      if (!isLoading)
        Positioned(
          right: context.isArabic ? 16.w : null,
          left: !context.isArabic ? 16.w : null,
          child: socialIcon,
        ),
    ],
  );
}
