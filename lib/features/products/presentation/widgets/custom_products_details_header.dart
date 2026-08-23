import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/extensions.dart';
import '../../../../core/widgets/custom_arrow_back.dart';
import '../../../../core/widgets/custom_network_image.dart';

class CustomProductsDetailsHeader extends StatelessWidget {
  const CustomProductsDetailsHeader({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: .topCenter,
    children: [
      Positioned(
        top: -450,
        child: Container(
          alignment: .bottomCenter,
          width: 700.w,
          height: 906.h,
          decoration: BoxDecoration(
            color: context.colors.surface,
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        top: 120.h,
        child: CustomNetworkImage(image: imagePath, height: 180.h),
      ),
      PositionedDirectional(
        top: 45.h,
        start: 15.w,
        child: CustomArrowBack(onTap: () => context.pop(), padding: .all(8.r)),
      ),
    ],
  );
}
