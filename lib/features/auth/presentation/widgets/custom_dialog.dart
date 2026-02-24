import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/theming/app_colors.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/generated/assets.dart';
import 'package:gap/gap.dart';
import '../../../../core/widgets/custom_material_button.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({super.key, required this.text, required this.onPressed});

  final String text;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        elevation: 0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.r)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(Assets.svgsSuccess),
              Gap(16.h),
              Text(
                text,
                textAlign: TextAlign.center,
                style: AppTextStyles.font16color0C0D0DSemiBold,
              ),
              Gap(16.h),
              CustomMaterialButton(
                onPressed: onPressed,
                text: "ok".tr(),
                maxWidth: true,
                textStyle: AppTextStyles.font16WhiteBold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
