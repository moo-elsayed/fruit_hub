import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.only(bottom: 8.h, start: 4.w),
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: AppTextStyles.font13SemiBold.copyWith(
          color: context.colors.subText,
        ),
      ),
    ),
  );
}
