import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/extensions.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/widgets/custom_arrow_back.dart';
import '../../../../core/widgets/custom_network_image.dart';

class CustomProductsDetailsHeader extends StatelessWidget {
  const CustomProductsDetailsHeader({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: .topCenter,
      children: [
        Positioned(
          top: -500,
          child: Container(
            alignment: .bottomCenter,
            width: 700.w,
            height: 906.h,
            decoration: const BoxDecoration(
              color: AppColors.colorF3F5F7,
              shape: .circle,
            ),
          ),
        ),
        Positioned(
          top: 70.h,
          child: CustomNetworkImage(image: imagePath, height: 180.h),
        ),
        PositionedDirectional(
          top: 20.h,
          start: 10.w,
          child: CustomArrowBack(
            onTap: () => context.pop(),
            padding: .all(8.r),
          ),
        ),
      ],
    );
  }
}
