import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';

class ReceiptInfoRow extends StatelessWidget {
  const ReceiptInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18.sp, color: context.colors.primary),
      Gap(8.w),
      Text(
        label,
        style: AppTextStyles.font13Regular.copyWith(
          color: context.colors.subText,
        ),
      ),
      Gap(16.w),
      Expanded(
        child: Text(
          value,
          style: AppTextStyles.font13SemiBold.copyWith(
            color: context.colors.mainText,
          ),
          textAlign: TextAlign.end,
        ),
      ),
    ],
  );
}
