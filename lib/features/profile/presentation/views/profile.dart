import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/custom_profile_item.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/sign_out_button.dart';
import 'package:gap/gap.dart';
import '../../domain/entities/profile_item_entity.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: .symmetric(horizontal: 16.w),
    child: Column(
      crossAxisAlignment: .start,
      children: [
        CustomAppBar(title: 'my_account'.tr()),
        Gap(16.h),
        Text(
          'general'.tr(),
          style: AppTextStyles.font13SemiBold.copyWith(
            color: context.colors.mainText,
          ),
        ),
        Gap(16.h),
        Expanded(
          child: ListView.separated(
            itemCount: getProfileItems(context).length,
            itemBuilder: (context, index) {
              final profileItemEntity = getProfileItems(context)[index];
              return CustomProfileItem(entity: profileItemEntity);
            },
            separatorBuilder: (context, index) =>
                Divider(color: context.colors.border),
          ),
        ),
        const Spacer(),
        Padding(
          padding: .only(bottom: 16.h),
          child: const SignOutButton(),
        ),
      ],
    ),
  );
}
