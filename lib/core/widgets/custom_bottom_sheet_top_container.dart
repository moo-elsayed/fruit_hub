import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theming/app_colors.dart';

class CustomBottomSheetTopContainer extends StatelessWidget {
  const CustomBottomSheetTopContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 4.h,
      margin: .only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.color131F46,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
