import 'package:flutter/material.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class OrderSummaryRow extends StatelessWidget {
  const OrderSummaryRow({
    super.key,
    required this.title,
    required this.value,
    this.freeShipping = false,
  });

  final String title;
  final String value;
  final bool freeShipping;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: AppTextStyles.font13SemiBold.copyWith(
          color: context.colors.subText,
        ),
      ),
      Text(
        value,
        style: AppTextStyles.font13SemiBold.copyWith(
          color: freeShipping
              ? context.colors.primary
              : context.colors.mainText,
        ),
      ),
    ],
  );
}
