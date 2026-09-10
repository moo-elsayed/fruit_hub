import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

class EditProfileCardContainer extends StatelessWidget {
  const EditProfileCardContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.r),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: context.colors.border, width: 1.w),
      boxShadow: [
        BoxShadow(
          color: context.colors.mainText.withValues(alpha: 0.02),
          blurRadius: 8.r,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}
