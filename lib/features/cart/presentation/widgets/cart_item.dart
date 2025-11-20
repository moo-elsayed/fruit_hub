import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/widgets/custom_action_button.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/generated/assets.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_network_image.dart';

class CartItem extends StatefulWidget {
  const CartItem({super.key, required this.size, required this.cartItemEntity});

  final Size size;
  final CartItemEntity cartItemEntity;

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  bool _isEnable = true;

  void _handleQuantityChange(bool isIncrement) async {
    if (!_isEnable) return;

    setState(() => _isEnable = false);

    if (isIncrement) {
      context.read<CartCubit>().incrementItemQuantity(
        widget.cartItemEntity.fruitEntity.code,
      );
    } else {
      context.read<CartCubit>().decrementItemQuantity(
        widget.cartItemEntity.fruitEntity.code,
      );
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isEnable = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
      height: widget.size.height * 0.11699,
      child: Row(
        children: [
          Container(
            width: widget.size.width * 0.19466,
            height: widget.size.height * 0.1133,
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10.w),
            color: AppColors.colorF3F5F7,
            child: CustomNetworkImage(
              image: widget.cartItemEntity.fruitEntity.imagePath,
            ),
          ),
          Gap(17.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              child: Column(
                crossAxisAlignment: .start,
                mainAxisAlignment: .spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    crossAxisAlignment: .start,
                    children: [
                      Column(
                        spacing: 3.h,
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            widget.cartItemEntity.fruitEntity.name,
                            style: AppTextStyles.font13color06161CBold,
                          ),
                          Text(
                            "${widget.cartItemEntity.quantity} ${"per_kilo".tr()}",
                            style: AppTextStyles.font13colorF4A91FRegular,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<CartCubit>().removeItemFromCart(
                            widget.cartItemEntity.fruitEntity.code,
                          );
                        },
                        child: SvgPicture.asset(Assets.iconsTrash),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 16.w,
                    children: [
                      CustomActionButton(
                        onTap: () {
                          _handleQuantityChange(true);
                        },
                        opacity: _isEnable ? 1 : 0.5,
                        radius: 12.r,
                        child: SvgPicture.asset(
                          Assets.iconsPlus,
                          height: 10.h,
                          width: 10.w,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      Text(
                        "${widget.cartItemEntity.quantity}",
                        style: AppTextStyles.font16color06140CBold,
                      ),
                      CustomActionButton(
                        onTap: () {
                          _handleQuantityChange(false);
                        },
                        opacity: _isEnable ? 1 : 0.5,
                        radius: 12.r,
                        backgroundColor: AppColors.colorF3F5F7,
                        child: SvgPicture.asset(
                          Assets.iconsIconsMinus,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${getPrice(widget.cartItemEntity.totalPrice)} ${"pounds".tr()}",
                        style: AppTextStyles.font13colorF4A91FBold,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
