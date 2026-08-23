import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../helpers/extensions.dart';

class CustomBottomSheetTopContainer extends StatelessWidget {
  const CustomBottomSheetTopContainer({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 60.w,
    height: 4.h,
    margin: .only(bottom: 8.h),
    decoration: BoxDecoration(
      color: context.colors.subText.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(16),
    ),
  );
}
