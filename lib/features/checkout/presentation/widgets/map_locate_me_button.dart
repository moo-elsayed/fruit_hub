import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

class MapLocateMeButton extends StatelessWidget {
  const MapLocateMeButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Positioned(
    bottom: 180.h,
    right: 20.w,
    child: Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: context.colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.border, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: context.colors.mainText.withValues(alpha: 0.08),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Icon(
              Icons.my_location_rounded,
              color: context.colors.primary,
              size: 22.sp,
            ),
          ),
        ),
      ),
    ),
  );
}
