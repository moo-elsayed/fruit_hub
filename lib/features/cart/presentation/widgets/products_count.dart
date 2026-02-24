import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

class ProductsCount extends StatelessWidget {
  const ProductsCount({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.symmetric(vertical: 10.h),
      width: double.infinity,
      alignment: Alignment.center,
      color: AppColors.colorEBF9F1,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "you_have".tr(),
              style: AppTextStyles.font13color1B5E37Regular,
            ),
            TextSpan(
              text: " $count ",
              style: AppTextStyles.font13color1B5E37Regular,
            ),
            TextSpan(
              text: "products_in_the_shopping_cart".tr(),
              style: AppTextStyles.font13color1B5E37Regular,
            ),
          ],
        ),
      ),
    );
  }
}
