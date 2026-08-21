import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';
import 'package:toastification/toastification.dart';

class AppToast {
  static bool isEnabled = true;

  static void show({
    required BuildContext context,
    required String title,
    String? description,
    required ToastificationType type,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    if (!isEnabled) return;

    final statusColor = type.getColor(context);

    toastification.showCustom(
      context: context,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 2, milliseconds: 500),
      animationBuilder: (context, animation, alignment, child) =>
          FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, -0.4),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutBack,
                    ),
                  ),
              child: child,
            ),
          ),
      builder: (BuildContext context, ToastificationItem holder) => Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: () {
            toastification.dismiss(holder);
            onTap?.call();
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Modern Badge Icon Container
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon ?? type.stateIcon,
                    color: statusColor,
                    size: 22.sp,
                  ),
                ),
                Gap(12.w),

                // Title & Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.font14Bold.copyWith(
                          color: context.colors.mainText,
                          height: 1.2,
                        ),
                      ),
                      if (description != null && description.isNotEmpty) ...[
                        Gap(4.h),
                        Text(
                          description,
                          style: AppTextStyles.font13Regular.copyWith(
                            color: context.colors.bodyText,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Gap(8.w),

                // Close Button
                InkWell(
                  onTap: () => toastification.dismiss(holder),
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      Icons.close_rounded,
                      color: context.colors.subText,
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
