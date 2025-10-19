import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/theming/app_colors.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_favourite_icon.dart';
import 'package:fruit_hub/generated/assets.dart';

class CustomFruitItem extends StatelessWidget {
  const CustomFruitItem({super.key, required this.fruitEntity});

  final FruitEntity fruitEntity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsetsGeometry.symmetric(
            vertical: 20.h,
            horizontal: 10.w,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadiusGeometry.circular(4.r),
            color: AppColors.colorF3F5F7,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              fruitEntity.imagePath == ''
                  ? Image.asset(Assets.imagesWatermelonTest)
                  : CachedNetworkImage(imageUrl: fruitEntity.imagePath),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4.h,
                    children: [
                      Text(
                        fruitEntity.name,
                        style: AppTextStyles.font13color0C0D0DSemiBold,
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${fruitEntity.price}${"pounds".tr()}",
                              style: AppTextStyles.font13colorF4A91FSemiBold,
                            ),
                            TextSpan(
                              text: " / ${"kilo".tr()}",
                              style: AppTextStyles.font13colorF8C76DSemiBold,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: CircleAvatar(
                      radius: 18.r,
                      backgroundColor: AppColors.color1B5E37,
                      child: SvgPicture.asset(Assets.iconsPlus),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        PositionedDirectional(
          start: 4.w,
          top: 4.h,
          child: CustomFavouriteIcon(isFavourite: false, onChanged: () {}),
        ),
      ],
    );
  }
}
