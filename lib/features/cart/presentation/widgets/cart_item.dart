import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/generated/assets.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_network_image.dart';

class CartItem extends StatelessWidget {
  const CartItem({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Container(
            width: size.width * 0.19466,
            padding: EdgeInsetsGeometry.symmetric(
              vertical: 26.h,
              horizontal: 10.w,
            ),
            color: AppColors.colorF3F5F7,
            child: const CustomNetworkImage(),
          ),
          Gap(17.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      spacing: 2.h,
                      children: [
                        Text("بطيخ", style: AppTextStyles.font13color06161CBold),
                        Text("3 ${""}", style: AppTextStyles.font13colorF4A91FRegular),
                      ],
                    ),
                    SvgPicture.asset(Assets.iconsTrash),
                  ],
                ),
                const Row(children: []),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
