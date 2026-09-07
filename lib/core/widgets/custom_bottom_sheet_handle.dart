import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

class CustomBottomSheetHandle extends StatelessWidget {
  const CustomBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 36.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: colors.subText.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}
