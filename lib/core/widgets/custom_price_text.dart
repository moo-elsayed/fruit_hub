import 'package:flutter/material.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class CustomPriceText extends StatelessWidget {
  const CustomPriceText({
    super.key,
    required this.price,
    this.priceStyle,
    this.currencyStyle,
    this.color,
    this.isLarge = false,
  });

  final num price;
  final TextStyle? priceStyle;
  final TextStyle? currencyStyle;
  final Color? color;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colors.secondary;
    final effectivePriceStyle =
        priceStyle ??
        (isLarge
            ? AppTextStyles.font18Bold.copyWith(color: effectiveColor)
            : AppTextStyles.font16Bold.copyWith(color: effectiveColor));
    final effectiveCurrencyStyle =
        currencyStyle ??
        (isLarge
            ? AppTextStyles.font13SemiBold.copyWith(color: effectiveColor)
            : AppTextStyles.font12SemiBold.copyWith(color: effectiveColor));

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '${price.formattedPrice}', style: effectivePriceStyle),
          const TextSpan(text: ' '),
          TextSpan(text: AppStrings.pounds, style: effectiveCurrencyStyle),
        ],
      ),
    );
  }
}
