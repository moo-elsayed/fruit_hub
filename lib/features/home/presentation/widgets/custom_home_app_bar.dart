import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/features/home/presentation/managers/home_cubit/home_cubit.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/notification_widget.dart';
import 'package:fruit_hub/generated/assets.dart';
import 'package:gap/gap.dart';

class CustomHomeAppBar extends StatelessWidget {
  const CustomHomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Image.asset(Assets.imagesProfileImage, height: 44.h, width: 44.w),
          Gap(11.w),
          Column(
            spacing: 2.h,
            crossAxisAlignment: .start,
            children: [
              Text(
                "good_morning".tr(),
                style: AppTextStyles.font16color949D9ERegular,
              ),
              Text(
                context.read<HomeCubit>().getUserName(),
                style: AppTextStyles.font16color0C0D0DSemiBold,
              ),
            ],
          ),
          const Spacer(),
          const NotificationWidget(),
        ],
      ),
    );
  }
}
