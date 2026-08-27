import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/custom_profile_item.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/sign_out_button.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/user_profile_card.dart';
import 'package:gap/gap.dart';
import '../../domain/entities/profile_item_entity.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final profileItems = getProfileItems(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBar(title: AppStrings.myAccount),
          Gap(12.h),
          const UserProfileCard(),
          Gap(20.h),
          Text(
            AppStrings.general,
            style: AppTextStyles.font13SemiBold.copyWith(
              color: context.colors.mainText,
            ),
          ),
          Gap(12.h),
          Expanded(
            child: ListView.separated(
              itemCount: profileItems.length,
              itemBuilder: (context, index) =>
                  CustomProfileItem(entity: profileItems[index]),
              separatorBuilder: (context, index) =>
                  Divider(color: context.colors.border),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 85.h),
            child: const SignOutButton(),
          ),
        ],
      ),
    );
  }
}
