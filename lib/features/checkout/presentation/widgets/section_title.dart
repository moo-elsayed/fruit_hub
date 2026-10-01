import 'package:flutter/material.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          title,
          style: AppTextStyles.font16Bold.copyWith(
            color: context.colors.mainText,
          ),
        ),
      ),
      if (onActionTap != null)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onActionTap,
          child: Text(
            actionText ?? AppStrings.edit,
            style: AppTextStyles.font13Bold.copyWith(
              color: context.colors.primary,
            ),
          ),
        ),
    ],
  );
}
