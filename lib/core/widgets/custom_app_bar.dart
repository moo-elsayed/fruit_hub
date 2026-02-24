import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../theming/app_text_styles.dart';
import 'custom_arrow_back.dart';
import 'notification_widget.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.showArrowBack = false,
    this.showNotification = false,
    this.centerTitle = true,
    this.onTap,
  });

  final String title;
  final bool showArrowBack;
  final VoidCallback? onTap;
  final bool showNotification;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showArrowBack
          ? Padding(
              padding: EdgeInsetsDirectional.only(start: 16.w),
              child: CustomArrowBack(onTap: onTap),
            )
          : null,
      title: Text(title, style: AppTextStyles.font19color0C0D0DBold),
      centerTitle: centerTitle,
      actions: showNotification
          ? [const NotificationWidget(), Gap(16.w)]
          : null,
    );
  }
}
