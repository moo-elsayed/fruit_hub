import 'package:flutter/material.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class OnboardingItemTitle extends StatelessWidget {
  const OnboardingItemTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.font22Bold.copyWith(
      color: context.colors.mainText,
    );

    if (title.endsWith('FruitHUB')) {
      final prefix = title.substring(0, title.length - 8);
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(text: prefix, style: baseStyle),
            TextSpan(
              text: 'Fruit',
              style: AppTextStyles.font22Bold.copyWith(
                color: context.colors.primary,
              ),
            ),
            TextSpan(
              text: 'HUB',
              style: AppTextStyles.font22Bold.copyWith(
                color: context.colors.secondary,
              ),
            ),
          ],
        ),
      );
    }

    return Text(title, textAlign: TextAlign.center, style: baseStyle);
  }
}
