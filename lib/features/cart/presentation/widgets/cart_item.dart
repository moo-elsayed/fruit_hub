import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_network_image.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_item_action_buttons.dart';
import 'package:gap/gap.dart';

class CartItem extends StatelessWidget {
  const CartItem({super.key, required this.cartItemEntity});

  final CartItemEntity cartItemEntity;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(16.r),
    onTap: () => context.pushNamed(
      Routes.productDetailsView,
      arguments: cartItemEntity.fruitEntity,
    ),
    child: Container(
      padding: EdgeInsets.all(12.r),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox.square(
              dimension: 76.r,
              child: CustomNetworkImage(
                image: cartItemEntity.fruitEntity.imagePath,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cartItemEntity.fruitEntity.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.font14Bold.copyWith(
                              color: context.colors.mainText,
                            ),
                          ),
                          Gap(2.h),
                          Text(
                            '${cartItemEntity.fruitEntity.price.formattedPrice} ${AppStrings.pounds} / ${AppStrings.kilo}',
                            style: AppTextStyles.font12Medium.copyWith(
                              color: context.colors.subText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(8.w),
                    InkWell(
                      borderRadius: BorderRadius.circular(8.r),
                      onTap: () {
                        context.read<CartCubit>().removeItemFromCart(
                          cartItemEntity.fruitEntity.code,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: context.colors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: SvgPicture.asset(
                          AppAssets.iconsTrash,
                          width: 16.r,
                          height: 16.r,
                          colorFilter: ColorFilter.mode(
                            context.colors.error,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(10.h),
                CartItemActionButtons(cartItemEntity: cartItemEntity),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
