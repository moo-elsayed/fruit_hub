import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/user_avatar_widget.dart';
import 'package:gap/gap.dart';

class EditProfileHeaderCard extends StatelessWidget {
  const EditProfileHeaderCard({super.key, required this.imageController});

  final TextEditingController imageController;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserInfoCubit>().currentUser;
    final displayName = user?.name ?? '';
    final email = user?.email ?? '';
    final isVerified = user?.isVerified ?? false;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.colors.border, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: context.colors.mainText.withValues(alpha: 0.03),
            blurRadius: 12.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: imageController,
            builder: (context, value, _) =>
                UserAvatarWidget(imagePath: value.text, size: 80),
          ),
          Gap(12.h),
          Text(
            displayName.isNotEmpty ? displayName : AppStrings.welcome,
            style: AppTextStyles.font16Bold.copyWith(
              color: context.colors.mainText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (email.isNotEmpty) ...[
            Gap(4.h),
            Text(
              email,
              style: AppTextStyles.font13Regular.copyWith(
                color: context.colors.subText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
          Gap(12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: isVerified
                  ? context.colors.primary.withValues(alpha: 0.1)
                  : context.colors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isVerified
                    ? context.colors.primary.withValues(alpha: 0.25)
                    : context.colors.error.withValues(alpha: 0.2),
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 5.w,
              children: [
                Icon(
                  isVerified
                      ? Icons.verified_rounded
                      : Icons.info_outline_rounded,
                  size: 14.sp,
                  color: isVerified
                      ? context.colors.primary
                      : context.colors.error,
                ),
                Text(
                  isVerified
                      ? AppStrings.verifiedAccount
                      : AppStrings.pleaseVerifyYourEmail,
                  style: AppTextStyles.font11SemiBold.copyWith(
                    color: isVerified
                        ? context.colors.primary
                        : context.colors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
