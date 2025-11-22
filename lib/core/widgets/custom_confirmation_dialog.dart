import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/theming/app_colors.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/generated/assets.dart';
import 'package:gap/gap.dart';
import '../helpers/extentions.dart';

class CustomConfirmationDialog extends StatelessWidget {
  const CustomConfirmationDialog({
    super.key,
    this.subtitle,
    required this.textConfirmButton,
    required this.textCancelButton,
    required this.title,
    required this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String? subtitle;
  final String textConfirmButton;
  final String textCancelButton;
  final void Function()? onCancel;
  final void Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      child: Padding(
        padding: .all(20.r),
        child: Column(
          mainAxisSize: .min,
          spacing: 12.h,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: SvgPicture.asset(Assets.iconsIconCancel),
              ),
            ),
            Text(title, style: AppTextStyles.font16color0C0D0DBold),
            if (subtitle != null)
              Text(subtitle!, style: AppTextStyles.font13color0C0D0DSemiBold),
            Gap(8.h),
            Row(
              spacing: 8.w,
              children: [
                Expanded(
                  child: CustomMaterialButton(
                    onPressed: onCancel ?? () => context.pop(),
                    text: textCancelButton,
                    textStyle: AppTextStyles.font16color1B5E37EBold,
                    color: AppColors.white,
                    side: const BorderSide(color: AppColors.color1B5E37),
                  ),
                ),
                Expanded(
                  child: CustomMaterialButton(
                    onPressed: onConfirm,
                    text: textConfirmButton,
                    textStyle: AppTextStyles.font16WhiteBold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
