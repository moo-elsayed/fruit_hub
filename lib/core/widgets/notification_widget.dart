import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../generated/assets.dart';
import '../theming/app_colors.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: AppColors.colorEEF8ED,
      radius: 18.r,
      child: SvgPicture.asset(
        Assets.iconsNotification,
        height: 20.h,
        width: 20.w,
      ),
    );
  }
}
