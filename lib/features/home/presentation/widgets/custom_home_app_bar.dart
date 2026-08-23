import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/home/presentation/managers/home_cubit/home_cubit.dart';
import 'package:gap/gap.dart';

class CustomHomeAppBar extends StatelessWidget {
  const CustomHomeAppBar({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w, vertical: 16.h),
    child: Row(
      crossAxisAlignment: .start,
      children: [
        Image.asset(AppAssets.imagesProfileImage, height: 44.h, width: 44.w),
        Gap(11.w),
        Column(
          spacing: 2.h,
          crossAxisAlignment: .start,
          children: [
            Text(
              AppStrings.goodMorning,
              style: AppTextStyles.font16Regular.copyWith(
                color: context.colors.subText,
              ),
            ),
            Text(
              context.read<HomeCubit>().getUserName,
              style: AppTextStyles.font16SemiBold.copyWith(
                color: context.colors.mainText,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
