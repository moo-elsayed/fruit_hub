import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class EditProfileSectionHeader extends StatelessWidget {
  const EditProfileSectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    spacing: 6.w,
    children: [
      Icon(icon, size: 18.sp, color: context.colors.primary),
      Text(
        title,
        style: AppTextStyles.font14Bold.copyWith(
          color: context.colors.mainText,
        ),
      ),
    ],
  );
}
