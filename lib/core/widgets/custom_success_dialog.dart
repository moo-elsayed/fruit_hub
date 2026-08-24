import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:gap/gap.dart';

class CustomSuccessDialog extends StatelessWidget {
  const CustomSuccessDialog({
    super.key,
    required this.text,
    required this.onPressed,
    this.buttonText,
  });

  final String text;
  final VoidCallback onPressed;
  final String? buttonText;

  static Future<T?> show<T>({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    String? buttonText,
  }) => showCupertinoDialog<T>(
    context: context,
    builder: (context) => CustomSuccessDialog(
      text: text,
      onPressed: onPressed,
      buttonText: buttonText,
    ),
  );

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: ShapeDecoration(
          color: context.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.r)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: context.colors.success,
              size: 48.sp,
            ),
            Gap(16.h),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.font16SemiBold.copyWith(
                color: context.colors.mainText,
              ),
            ),
            Gap(20.h),
            CustomMaterialButton(
              onPressed: onPressed,
              text: buttonText ?? AppStrings.ok,
              maxWidth: true,
              textStyle: AppTextStyles.font16Bold.copyWith(
                color: AppPalette.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
