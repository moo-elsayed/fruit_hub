import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:gap/gap.dart';

class CustomSliderItem extends StatelessWidget {
  const CustomSliderItem({super.key});

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsetsGeometry.symmetric(horizontal: 4.w),
    width: double.infinity,
    child: Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        PositionedDirectional(
          bottom: 5.h,
          end: 5.w,
          top: 0,
          start: MediaQuery.sizeOf(context).width * 0.35,
          child: Image.asset(AppAssets.imagesFruitsImage, fit: BoxFit.fill),
        ),
        Transform.rotate(
          angle: context.isArabic ? 0 : pi,
          child: ClipRRect(
            borderRadius: _buildBorderRadiusGeometry(context),
            child: SvgPicture.asset(AppAssets.svgsFeaturedItemBackground),
          ),
        ),
        PositionedDirectional(
          start: 25.w,
          bottom: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.eidOffers,
                style: AppTextStyles.font13Regular.copyWith(color: Colors.white),
              ),
              Gap(10.h),
              Text(
                '${AppStrings.discount} 25%',
                style: AppTextStyles.font19Bold.copyWith(color: Colors.white),
              ),
              Gap(7.h),
              CustomMaterialButton(
                onPressed: () {},
                text: AppStrings.shopNow,
                textStyle: AppTextStyles.font13Bold.copyWith(
                  color: context.colors.primary,
                ),
                padding: EdgeInsetsGeometry.symmetric(
                  vertical: 4.h,
                  horizontal: 28.w,
                ),
                backgroundColor: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
              Gap(29.h),
            ],
          ),
        ),
      ],
    ),
  );

  BorderRadiusGeometry _buildBorderRadiusGeometry(BuildContext context) {
    final arabic = context.isArabic;
    return BorderRadiusGeometry.directional(
      topStart: Radius.circular(arabic ? 4.r : 0),
      topEnd: Radius.circular(arabic ? 0.r : 4.r),
      bottomStart: Radius.circular(arabic ? 4.r : 0),
      bottomEnd: Radius.circular(arabic ? 0 : 4.r),
    );
  }
}
