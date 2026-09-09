import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../helpers/app_assets.dart';
import '../helpers/extensions.dart';
import '../theming/app_palette.dart';
import '../theming/app_text_styles.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({super.key, this.onTap, this.unreadCount = 0});

  final VoidCallback? onTap;
  final int unreadCount;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          backgroundColor: context.colors.primary.withValues(alpha: 0.1),
          radius: 18.r,
          child: SvgPicture.asset(
            AppAssets.iconsNotification,
            height: 20.h,
            width: 20.w,
            colorFilter: ColorFilter.mode(
              context.colors.primary.withValues(alpha: 0.8),
              BlendMode.srcIn,
            ),
          ),
        ),
        if (unreadCount > 0)
          PositionedDirectional(
            top: -2.h,
            end: -2.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              constraints: BoxConstraints(minWidth: 16.r, minHeight: 16.r),
              decoration: BoxDecoration(
                color: context.colors.error,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: context.colors.surface, width: 1.5.w),
              ),
              alignment: Alignment.center,
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: AppTextStyles.font10Bold.copyWith(
                  color: AppPalette.white,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    ),
  );
}
