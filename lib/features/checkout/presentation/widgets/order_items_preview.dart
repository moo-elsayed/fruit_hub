import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_network_image.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';
import 'package:fruit_hub/core/widgets/snap_scroll_physics.dart';
import 'package:gap/gap.dart';

class OrderItemsPreview extends StatelessWidget {
  const OrderItemsPreview({super.key, required this.products});

  final List<CartItemEntity> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.orderedItems,
                style: AppTextStyles.font14Bold.copyWith(
                  color: context.colors.mainText,
                ),
              ),
              Gap(6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${products.length}',
                  style: AppTextStyles.font12Bold.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Gap(12.h),
        SizedBox(
          height: 96.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            clipBehavior: Clip.none,
            physics: SnapScrollPhysics(
              itemExtent: 220.w + 12.w,
              parent: const BouncingScrollPhysics(),
            ),
            itemCount: products.length,
            separatorBuilder: (context, index) => Gap(12.w),
            itemBuilder: (context, index) {
              final item = products[index];

              return Container(
                width: 220.w,
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? context.colors.surface
                      : AppPalette.bgLightSecondary,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        width: 54.r,
                        height: 54.r,
                        color: context.colors.background,
                        child: CustomNetworkImage(
                          image: item.fruitEntity.imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Gap(10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.fruitEntity.name,
                            style: AppTextStyles.font13SemiBold.copyWith(
                              color: context.colors.mainText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Gap(4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.border,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'x${item.quantity}',
                                  style: AppTextStyles.font11Regular.copyWith(
                                    color: context.colors.subText,
                                  ),
                                ),
                              ),
                              CustomPriceText(price: item.totalPrice),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
