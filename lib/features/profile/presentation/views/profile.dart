import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/theming/app_colors.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/profile/presentation/widgets/custom_profile_item.dart';
import 'package:gap/gap.dart';
import '../../domain/entities/profile_item_entity.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBar(title: "my_account".tr()),
          Gap(16.h),
          Text("general".tr(), style: AppTextStyles.font13color0C0D0DSemiBold),
          Gap(16.h),
          Expanded(
            child: ListView.separated(
              itemCount: getProfileItems(context).length,
              itemBuilder: (context, index) {
                var profileItemEntity = getProfileItems(context)[index];
                return CustomProfileItem(entity: profileItemEntity);
              },
              separatorBuilder: (context, index) =>
                  const Divider(color: AppColors.colorF2F3F3),
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsetsGeometry.only(bottom: 16.h),
            child: CustomMaterialButton(
              onPressed: () {},
              text: "sign_out".tr(),
              textStyle: AppTextStyles.font16WhiteBold,
              maxWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
