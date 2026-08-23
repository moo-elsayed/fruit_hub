import 'package:flutter/material.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import '../theming/app_text_styles.dart';

class PricePerKilo extends StatelessWidget {
  const PricePerKilo({super.key, required this.price});

  final double price;

  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: '${price.formattedPrice} ${AppStrings.pounds}',
          style: AppTextStyles.font13SemiBold.copyWith(
            color: context.colors.secondary,
          ),
        ),
        TextSpan(
          text: ' / ${AppStrings.kilo}',
          style: AppTextStyles.font13SemiBold.copyWith(
            color: AppPalette.secondaryOrangeLight,
          ),
        ),
      ],
    ),
  );
}
