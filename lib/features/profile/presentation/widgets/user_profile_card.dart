import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/user_avatar_widget.dart';
import 'package:gap/gap.dart';

class UserProfileCard extends StatelessWidget {
  const UserProfileCard({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<UserInfoCubit, UserInfoState>(
        builder: (context, state) {
          final user = state is UserInfoSuccess
              ? state.user
              : context.read<UserInfoCubit>().currentUser;
          final displayName = user?.name.isNotEmpty == true
              ? user!.name
              : AppStrings.welcome;
          final displayEmail = user?.email ?? '';

          return GestureDetector(
            onTap: () => context.pushNamed(Routes.editProfileView),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: context.colors.border, width: 1.w),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.mainText.withValues(alpha: 0.03),
                    blurRadius: 10.r,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  UserAvatarWidget(imagePath: user?.image),
                  Gap(14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayName,
                          style: AppTextStyles.font16Bold.copyWith(
                            color: context.colors.mainText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (displayEmail.isNotEmpty) ...[
                          Gap(2.h),
                          Text(
                            displayEmail,
                            style: AppTextStyles.font13Regular.copyWith(
                              color: context.colors.subText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18.sp,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
