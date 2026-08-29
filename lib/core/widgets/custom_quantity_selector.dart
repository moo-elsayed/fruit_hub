import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_action_button.dart';

class CustomQuantitySelector extends StatelessWidget {
  const CustomQuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.isEnabled = true,
    this.isDecrementEnabled = true,
    this.isLarge = false,
    this.radius,
    this.iconSize,
    this.textStyle,
    this.padding,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isEnabled;
  final bool isDecrementEnabled;
  final bool isLarge;
  final double? radius;
  final double? iconSize;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = radius ?? (isLarge ? 16.r : 12.r);
    final effectiveIconSize = iconSize ?? (isLarge ? 13.r : 10.r);
    final effectivePadding =
        padding ??
        (isLarge
            ? EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h)
            : EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h));
    final effectiveTextStyle =
        textStyle ??
        (isLarge
            ? AppTextStyles.font16Bold.copyWith(color: context.colors.mainText)
            : AppTextStyles.font14Bold.copyWith(
                color: context.colors.mainText,
              ));

    return Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(isLarge ? 28.r : 20.r),
        border: Border.all(color: context.colors.border, width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: isLarge ? 14.w : 10.w,
        children: [
          CustomActionButton(
            onTap: isEnabled ? onIncrement : () {},
            opacity: isEnabled ? 1 : 0.5,
            radius: effectiveRadius,
            child: SvgPicture.asset(
              AppAssets.iconsPlus,
              height: effectiveIconSize,
              width: effectiveIconSize,
              fit: BoxFit.scaleDown,
            ),
          ),
          Text('$quantity', style: effectiveTextStyle),
          CustomActionButton(
            onTap: (isEnabled && isDecrementEnabled) ? onDecrement : () {},
            opacity: (isEnabled && isDecrementEnabled) ? 1 : 0.5,
            radius: effectiveRadius,
            backgroundColor: context.colors.background,
            border: Border.all(color: context.colors.border, width: 1.w),
            child: SvgPicture.asset(
              AppAssets.iconsIconsMinus,
              height: effectiveIconSize,
              width: effectiveIconSize,
              fit: BoxFit.scaleDown,
            ),
          ),
        ],
      ),
    );
  }
}
