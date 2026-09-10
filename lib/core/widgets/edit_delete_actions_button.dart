import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

class EditDeleteActionButtons extends StatelessWidget {
  const EditDeleteActionButtons({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: context.colors.primary.withValues(alpha: 0.15)),
    ),
    child: Material(
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onEdit,
            splashFactory: NoSplash.splashFactory,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(8.r)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Icon(
                Icons.edit_rounded,
                color: context.colors.primary,
                size: 16.sp,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 16.h,
            color: context.colors.primary.withValues(alpha: 0.2),
          ),
          InkWell(
            onTap: onDelete,
            splashFactory: NoSplash.splashFactory,
            borderRadius: BorderRadius.horizontal(right: Radius.circular(8.r)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Icon(
                Icons.delete_outline_rounded,
                color: context.colors.error,
                size: 16.sp,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
