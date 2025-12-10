import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import '../../../../core/helpers/functions.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_action_button.dart';
import '../../../../generated/assets.dart';
import '../managers/cart_cubit/cart_cubit.dart';

class CartItemActionButtons extends StatefulWidget {
  const CartItemActionButtons({super.key, required this.cartItemEntity});

  final CartItemEntity cartItemEntity;

  @override
  State<CartItemActionButtons> createState() => _CartItemActionButtonsState();
}

class _CartItemActionButtonsState extends State<CartItemActionButtons> {
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
    return Row(
      spacing: 16.w,
      children: [
        CustomActionButton(
          onTap: () => _handleQuantityChange(true),
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
          onTap: () => _handleQuantityChange(false),
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
    );
  }
}
