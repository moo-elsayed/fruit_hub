import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/generated/assets.dart';
import 'package:gap/gap.dart';
import '../helpers/extensions.dart';
import '../theming/app_text_styles.dart';
import 'custom_material_button.dart';

class CustomConfirmationDialog extends StatelessWidget {
  const CustomConfirmationDialog({
    super.key,
    this.subtitle,
    required this.textConfirmButton,
    this.textCancelButton,
    required this.title,
    required this.onConfirm,
    this.onCancel,
    this.showCancelButton = true,
  });

  final String title;
  final String textConfirmButton;
  final bool showCancelButton;
  final String? subtitle;
  final String? textCancelButton;
  final void Function()? onCancel;
  final void Function() onConfirm;

  @override
  Widget build(BuildContext context) => Dialog(
    alignment: Alignment.center,
    insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
    backgroundColor: context.colors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
    child: Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GestureDetector(
              onTap: () => context.pop(),
              behavior: HitTestBehavior.opaque,
              child: SvgPicture.asset(
                Assets.iconsIconCancel,
                colorFilter: ColorFilter.mode(
                  context.colors.subText,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Gap(8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.font16SemiBold.copyWith(
              color: context.colors.mainText,
            ),
          ),
          if (subtitle != null) ...[
            Gap(8.h),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTextStyles.font14Regular.copyWith(
                color: context.colors.subText,
                height: 1.5,
              ),
            ),
          ],
          Gap(24.h),
          showCancelButton
              ? Row(
                  children: [
                    Expanded(
                      child: CustomMaterialButton(
                        onPressed: onCancel ?? () => context.pop(),
                        text: textCancelButton ?? AppStrings.cancel,
                        textStyle: AppTextStyles.font16SemiBold.copyWith(
                          color: context.colors.primary,
                        ),
                        backgroundColor: Colors.transparent,
                        side: BorderSide(
                          color: context.colors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomMaterialButton(
                        onPressed: onConfirm,
                        text: textConfirmButton,
                        textStyle: AppTextStyles.font16SemiBold.copyWith(
                          color: Colors.white,
                        ),
                        backgroundColor: context.colors.primary,
                      ),
                    ),
                  ],
                )
              : CustomMaterialButton(
                  onPressed: onConfirm,
                  text: textConfirmButton,
                  textStyle: AppTextStyles.font16SemiBold.copyWith(
                    color: Colors.white,
                  ),
                  backgroundColor: context.colors.primary,
                ),
        ],
      ),
    ),
  );
}
