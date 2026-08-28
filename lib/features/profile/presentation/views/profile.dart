import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/main_screen_header.dart';
import 'package:fruit_hub/features/profile/presentation/helpers/profile_helpers.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/profile_card.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/profile_section_title.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/sign_out_button.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/user_profile_card.dart';
import 'package:gap/gap.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild on locale change so trailing texts update dynamically
    final _ = EasyLocalization.of(context)?.locale;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
      child: Column(
        children: [
          MainScreenHeader(title: AppStrings.myAccount),
          Gap(16.h),
          const UserProfileCard(),
          Gap(24.h),
          ProfileSectionTitle(title: AppStrings.general),
          ProfileCard(items: getProfileItems(context)),
          Gap(32.h),
          const SignOutButton(),
        ],
      ),
    );
  }
}
