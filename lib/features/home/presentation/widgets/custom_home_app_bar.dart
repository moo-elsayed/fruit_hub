import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/notification_widget.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:gap/gap.dart';

class CustomHomeAppBar extends StatelessWidget {
  const CustomHomeAppBar({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(AppAssets.imagesProfileImage, height: 44.r, width: 44.r),
        Gap(11.w),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.goodMorning,
                style: AppTextStyles.font16Regular.copyWith(
                  color: context.colors.subText,
                ),
              ),
              Gap(2.h),
              BlocBuilder<UserInfoCubit, UserInfoState>(
                builder: (context, state) {
                  final user = state is UserInfoSuccess
                      ? state.user
                      : context.read<UserInfoCubit>().currentUser;
                  final userName = user?.name ?? '';

                  return Text(
                    userName,
                    style: AppTextStyles.font16SemiBold.copyWith(
                      color: context.colors.mainText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ],
          ),
        ),
        const NotificationWidget(),
      ],
    ),
  );
}
