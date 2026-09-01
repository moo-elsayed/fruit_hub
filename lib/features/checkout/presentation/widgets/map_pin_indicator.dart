import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

class MapPinIndicator extends StatelessWidget {
  const MapPinIndicator({super.key, this.isMoving = false});

  final bool isMoving;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.only(bottom: 36.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(0, isMoving ? -12.h : 0, 0),
            child: Icon(
              Icons.location_on_rounded,
              size: 48.sp,
              color: context.colors.primary,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isMoving ? 10.w : 16.w,
            height: isMoving ? 3.h : 5.h,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ],
      ),
    ),
  );
}
