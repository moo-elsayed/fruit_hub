import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

class MapCompassButton extends StatelessWidget {
  const MapCompassButton({
    super.key,
    required this.bearing,
    required this.onTap,
  });

  final double bearing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (bearing.abs() < 0.001) return const SizedBox.shrink();

    return Positioned(
      top: 50.h,
      left: context.isArabic ? 20.w : null,
      right: context.isArabic ? null : 20.w,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: context.colors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.border, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: context.colors.mainText.withValues(alpha: 0.06),
                blurRadius: 8.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Center(
              child: Transform.rotate(
                angle: -bearing * (math.pi / 180),
                child: Icon(
                  Icons.explore_rounded,
                  color: context.colors.primary,
                  size: 22.sp,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
