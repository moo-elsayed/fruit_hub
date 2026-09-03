import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:gap/gap.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/product_details_entity.dart';

class ProductDetailItem extends StatelessWidget {
  const ProductDetailItem({
    super.key,
    required this.productDetail,
    required this.index,
  });

  final ProductDetailsEntity productDetail;
  final int index;

  Color _getItemColor(BuildContext context) {
    switch (index % 3) {
      case 0:
        return context.colors.info;
      case 1:
        return context.colors.primary;
      case 2:
      default:
        return context.colors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemColor = _getItemColor(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.colors.border, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: context.colors.mainText.withValues(alpha: 0.02),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: itemColor.withValues(alpha: 0.1),
            ),
            child: SvgPicture.asset(
              productDetail.trailingAsset,
              colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
            ),
          ),
          Gap(8.h),
          Text(
            productDetail.title,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.font13Bold.copyWith(color: itemColor),
          ),
          Gap(2.h),
          Text(
            productDetail.subtitle,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.font11Medium.copyWith(
              color: context.colors.subText,
            ),
          ),
        ],
      ),
    );
  }
}
