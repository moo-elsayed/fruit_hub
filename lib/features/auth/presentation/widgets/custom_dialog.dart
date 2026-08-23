import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';
import '../../../../core/widgets/custom_material_button.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({super.key, required this.text, required this.onPressed});

  final String text;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Dialog(
      elevation: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: ShapeDecoration(
          color: context.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.r)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(AppAssets.svgsSuccess),
            Gap(16.h),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.font16SemiBold.copyWith(
                color: context.colors.mainText,
              ),
            ),
            Gap(16.h),
            CustomMaterialButton(
              onPressed: onPressed,
              text: AppStrings.ok,
              maxWidth: true,
              textStyle: AppTextStyles.font16Bold.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  );
}
