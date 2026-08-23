import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_check_box.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key, required this.onChanged});

  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    spacing: 16.w,
    children: [
      CustomCheckBox(onChanged: onChanged),
      Expanded(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: AppStrings.termsAndConditionsP1,
                style: AppTextStyles.font13SemiBold.copyWith(
                  color: context.colors.subText,
                ),
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text: AppStrings.termsAndConditionsP2,
                style: AppTextStyles.font13SemiBold.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
