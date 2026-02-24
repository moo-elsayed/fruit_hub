import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../generated/assets.dart';
import '../helpers/functions.dart';
import '../theming/app_colors.dart';

class CustomArrowBack extends StatelessWidget {
  const CustomArrowBack({super.key, required this.onTap, this.padding});

  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: AppColors.colorF1F1F5),
        ),
        child: Transform.rotate(
          angle: isArabic(context) ? 0 : pi,
          child: SvgPicture.asset(Assets.iconsArrowBack, fit: BoxFit.scaleDown),
        ),
      ),
    );
  }
}
