import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../helpers/app_assets.dart';
import '../helpers/extensions.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({super.key});

  @override
  Widget build(BuildContext context) => CircleAvatar(
    backgroundColor: context.colors.primary.withValues(alpha: 0.1),
    radius: 18.r,
    child: SvgPicture.asset(
      AppAssets.iconsNotification,
      height: 20.h,
      width: 20.w,
    ),
  );
}
