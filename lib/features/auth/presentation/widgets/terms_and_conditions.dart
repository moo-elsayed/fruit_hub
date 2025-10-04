import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'custom_check_box.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key, required this.onChanged});

  final ValueChanged<bool> onChanged;

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16.w,
      children: [
        CustomCheckBox(onChanged: widget.onChanged),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "terms_and_conditions_p1".tr(),
                  style: AppTextStyles.font13color949D9ESemiBold,
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: "terms_and_conditions_p2".tr(),
                  style: AppTextStyles.font13color2D9F5DSemiBold,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
