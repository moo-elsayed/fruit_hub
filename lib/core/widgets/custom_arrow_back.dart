import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import '../helpers/app_assets.dart';

class CustomArrowBack extends StatelessWidget {
  const CustomArrowBack({super.key, required this.onTap, this.padding});

  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: padding,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.surface,
        border: Border.all(color: context.colors.border),
      ),
      child: Transform.rotate(
        angle: context.isArabic ? 0 : pi,
        child: SvgPicture.asset(
          AppAssets.iconsArrowBack,
          fit: BoxFit.scaleDown,
        ),
      ),
    ),
  );
}
