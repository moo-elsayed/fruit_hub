import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/features/profile/domain/entities/profile_item_entity.dart';
import '../../../../core/helpers/functions.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../generated/assets.dart';

class CustomProfileItem extends StatelessWidget {
  const CustomProfileItem({super.key, required this.entity});

  final ProfileItemEntity entity;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8.w,
      children: [
        SvgPicture.asset(entity.leadingAsset),
        Text(entity.titleText, style: AppTextStyles.font13color949D9ESemiBold),
        const Spacer(),
        GestureDetector(
          onTap: entity.onTap,
          child: Row(
            children: [
              if (entity.trailingText != null)
                Text(
                  entity.trailingText!,
                  style: AppTextStyles.font13color0C0D0DSemiBold,
                ),
              Transform.rotate(
                angle: !isArabic(context) ? 0 : pi,
                child: SvgPicture.asset(
                  Assets.iconsArrowBack,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
