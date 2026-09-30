import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

import '../helpers/app_assets.dart';

class CustomCheckBox extends StatelessWidget {
  const CustomCheckBox({super.key, this.value = false});

  final bool value;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeInOut,
    width: 24.w,
    height: 24.h,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(
        color: !value ? context.colors.border : context.colors.primary,
        width: 1.5,
      ),
      color: value ? context.colors.primary : context.colors.surface,
    ),
    child: value
        ? Center(
            child: SvgPicture.asset(
              AppAssets.iconsCheck,
              width: 16.w,
              height: 16.h,
            ),
          )
        : null,
  );
}
