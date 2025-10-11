import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import '../../../../core/helpers/functions.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_material_button.dart';
import '../../../../generated/assets.dart';

class CustomSliderItem extends StatelessWidget {
  const CustomSliderItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsetsGeometry.symmetric(horizontal: 4.w),
      width: double.infinity,
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          PositionedDirectional(
            bottom: 0,
            end: 0,
            top: 0,
            start: MediaQuery.sizeOf(context).width * 0.35,
            child: Image.asset(Assets.imagesWatermelonTest, fit: BoxFit.fill),
          ),
          Transform.rotate(
            angle: isArabic(context) ? 0 : pi,
            child: ClipRRect(
              borderRadius: _buildBorderRadiusGeometry(context),
              child: SvgPicture.asset(Assets.svgsFeaturedItemBackground),
            ),
          ),
          PositionedDirectional(
            start: 25.w,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "eid_offers".tr(),
                  style: AppTextStyles.font13WhiteRegular,
                ),
                Gap(10.h),
                Text(
                  "${"discount".tr()} 25%",
                  style: AppTextStyles.font19WhiteDBold,
                ),
                Gap(7.h),
                CustomMaterialButton(
                  onPressed: () {},
                  text: "shop_now".tr(),
                  textStyle: AppTextStyles.font13color1B5E37Bold,
                  padding: EdgeInsetsGeometry.symmetric(
                    vertical: 4.h,
                    horizontal: 28.w,
                  ),
                  color: Colors.white,
                  borderRadius: BorderRadiusGeometry.circular(4.r),
                ),
                Gap(29.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BorderRadiusGeometry _buildBorderRadiusGeometry(BuildContext context) {
    var arabic = isArabic(context);
    return BorderRadiusGeometry.directional(
      topStart: Radius.circular(arabic ? 4.r : 0),
      topEnd: Radius.circular(arabic ? 0.r : 4.r),
      bottomStart: Radius.circular(arabic ? 4.r : 0),
      bottomEnd: Radius.circular(arabic ? 0 : 4.r),
    );
  }
}
