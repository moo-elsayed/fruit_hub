import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/profile/domain/entities/profile_item_entity.dart';

class CustomProfileItem extends StatelessWidget {
  const CustomProfileItem({super.key, required this.entity});

  final ProfileItemEntity entity;

  @override
  Widget build(BuildContext context) => Row(
    spacing: 8.w,
    children: [
      SvgPicture.asset(entity.leadingAsset),
      Text(
        entity.titleText,
        style: AppTextStyles.font13SemiBold.copyWith(
          color: context.colors.subText,
        ),
      ),
      const Spacer(),
      GestureDetector(
        onTap: entity.onTap,
        child: Row(
          children: [
            if (entity.trailingText != null)
              Text(
                entity.trailingText!,
                style: AppTextStyles.font13SemiBold.copyWith(
                  color: context.colors.mainText,
                ),
              ),
            Transform.rotate(
              angle: !context.isArabic ? 0 : pi,
              child: SvgPicture.asset(
                AppAssets.iconsArrowBack,
                fit: BoxFit.scaleDown,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
