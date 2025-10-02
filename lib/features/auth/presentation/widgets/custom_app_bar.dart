import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/helpers/functions.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../generated/assets.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.showArrowBack = false,
    this.onTap,
  });

  final String title;
  final bool showArrowBack;
  final void Function()? onTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Visibility(
        visible: showArrowBack,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: EdgeInsetsDirectional.only(start: 16.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.colorF1F1F5),
            ),
            child: Transform.rotate(
              angle: isArabic(context) ? 0 : pi,
              child: SvgPicture.asset(
                Assets.iconsArrowBack,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ),
      ),
      title: Text(title, style: AppTextStyles.font19color0C0D0DBold),
      centerTitle: true,
    );
  }
}
