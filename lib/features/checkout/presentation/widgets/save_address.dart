import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_check_box.dart';

class SaveAddress extends StatelessWidget {
  const SaveAddress({super.key, required this.onChanged, this.value = false});

  final ValueChanged<bool> onChanged;
  final bool value;

  @override
  Widget build(BuildContext context) => Row(
    spacing: 8.w,
    children: [
      CustomCheckBox(onChanged: onChanged, value: value),
      Text(
        AppStrings.saveAddress,
        style: AppTextStyles.font13SemiBold.copyWith(
          color: context.colors.subText,
        ),
      ),
    ],
  );
}
