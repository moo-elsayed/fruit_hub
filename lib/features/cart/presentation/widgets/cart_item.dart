import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/widgets/custom_action_button.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import 'package:fruit_hub/generated/assets.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_network_image.dart';

class CartItem extends StatelessWidget {
  const CartItem({super.key, required this.size, required this.cartItemEntity});

  final Size size;
  final CartItemEntity cartItemEntity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: size.width * 0.19466,
            padding: EdgeInsetsGeometry.symmetric(
              vertical: 26.h,
              horizontal: 10.w,
            ),
            color: AppColors.colorF3F5F7,
            child: CustomNetworkImage(
              image: cartItemEntity.fruitEntity.imagePath,
            ),
          ),
          Gap(17.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cartItemEntity.fruitEntity.name,
                      style: AppTextStyles.font13color06161CBold,
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: SvgPicture.asset(Assets.iconsTrash),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsetsGeometry.only(top: 2.h, bottom: 20.h),
                  child: Text(
                    "${cartItemEntity.quantity} ${"per_kilo".tr()}",
                    style: AppTextStyles.font13colorF4A91FRegular,
                  ),
                ),
                Row(
                  spacing: 16.w,
                  children: [
                    CustomActionButton(
                      onTap: () {},
                      radius: 12.r,
                      child: SvgPicture.asset(
                        Assets.iconsPlus,
                        height: 10.h,
                        width: 10.w,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Text(
                      "${cartItemEntity.quantity}",
                      style: AppTextStyles.font16color06140CBold,
                    ),
                    CustomActionButton(
                      onTap: () {},
                      radius: 12.r,
                      backgroundColor: AppColors.colorF3F5F7,
                      child: SvgPicture.asset(
                        Assets.iconsIconsMinus,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${getPrice(cartItemEntity.totalPrice)} ${"pounds".tr()}",
                      style: AppTextStyles.font13colorF4A91FBold,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
