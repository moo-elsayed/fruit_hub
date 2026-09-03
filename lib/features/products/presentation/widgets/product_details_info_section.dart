import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/price_per_kilo.dart';
import 'package:fruit_hub/core/widgets/product_badge.dart';
import 'package:gap/gap.dart';

class ProductDetailsInfoSection extends StatelessWidget {
  const ProductDetailsInfoSection({super.key, required this.fruit});

  final FruitEntity fruit;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    fruit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.font18Bold.copyWith(
                      color: context.colors.mainText,
                    ),
                  ),
                ),
                if (fruit.isOrganic || fruit.isFeatured) ...[
                  Gap(8.w),
                  if (fruit.isOrganic)
                    ProductBadge(
                      icon: Icons.eco_rounded,
                      color: context.colors.primary,
                      tooltip: AppStrings.organic,
                    ),
                  if (fruit.isOrganic && fruit.isFeatured) Gap(4.w),
                  if (fruit.isFeatured)
                    ProductBadge(
                      icon: Icons.star_rounded,
                      color: context.colors.starYellow,
                      tooltip: AppStrings.featured,
                    ),
                ],
              ],
            ),
          ),
          Gap(12.w),
          PricePerKilo(price: fruit.price),
        ],
      ),
      Gap(8.h),
      InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: () => context.pushNamed(Routes.reviewsView, arguments: fruit),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              size: 20.sp,
              color: context.colors.starYellow,
            ),
            Gap(4.w),
            Text(
              '${fruit.avgRating}',
              style: AppTextStyles.font14Bold.copyWith(
                color: context.colors.mainText,
              ),
            ),
            Gap(6.w),
            Text(
              '(${fruit.reviews.length} ${AppStrings.reviews})',
              style: AppTextStyles.font13Medium.copyWith(
                color: context.colors.primary,
                decoration: TextDecoration.underline,
                decorationColor: context.colors.primary,
              ),
            ),
          ],
        ),
      ),
      Gap(8.h),
      Text(
        fruit.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.font13Regular.copyWith(
          color: context.colors.subText,
          height: 1.4,
        ),
      ),
    ],
  );
}
