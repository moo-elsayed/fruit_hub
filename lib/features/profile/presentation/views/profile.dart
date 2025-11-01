import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/generated/assets.dart';
import '../../../../core/helpers/functions.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(title: "my_account".tr()),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
          child: Row(
            spacing: 8.w,
            children: [
              SvgPicture.asset(Assets.iconsLanguageIcon),
              Text(
                "language".tr(),
                style: AppTextStyles.font13color949D9ESemiBold,
              ),
              const Spacer(),
              Text(
                "app_language".tr(),
                style: AppTextStyles.font13color0C0D0DSemiBold,
              ),
              GestureDetector(
                onTap: () {},
                child: Transform.rotate(
                  angle: !isArabic(context) ? 0 : pi,
                  child: SvgPicture.asset(
                    Assets.iconsArrowBack,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        CustomMaterialButton(onPressed: () {}, text: "sign_out".tr(),maxWidth: true,),
      ],
    );
  }
}
