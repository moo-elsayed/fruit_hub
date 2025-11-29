import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_check_box.dart';

class SaveAddress extends StatelessWidget {
  const SaveAddress({super.key, required this.onChanged, this.value = false});

  final ValueChanged<bool> onChanged;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8.w,
      children: [
        CustomCheckBox(onChanged: onChanged, value: value),
        Text(
          "save_address".tr(),
          style: AppTextStyles.font13color949D9ESemiBold,
        ),
      ],
    );
  }
}
