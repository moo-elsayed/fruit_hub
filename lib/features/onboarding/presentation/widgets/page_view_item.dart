import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../data/models/onboarding_model.dart';

class PageViewItem extends StatelessWidget {
  const PageViewItem({super.key, required this.slide, required this.showSkip});

  final OnboardingModel slide;
  final bool showSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SvgPicture.asset(slide.backgroundImage, fit: BoxFit.fill),
            SvgPicture.asset(slide.image),
            if (showSkip)
              Positioned(
                top: 60.h,
                right: context.locale.languageCode == 'ar' ? 20.w : null,
                left: context.locale.languageCode == 'en' ? 20.w : null,
                child: Text(
                  "skip".tr(),
                  style: AppTextStyles.font13color949D9ERegular,
                ),
              ),
          ],
        ),
        Padding(
          padding: EdgeInsetsGeometry.only(right: 37.w, left: 37.w, top: 64.h),
          child: Column(
            children: [
              _getText(),
              Gap(24.h),
              Text(
                slide.description,
                textAlign: TextAlign.center,
                style: AppTextStyles.font13color4E5556FSemiBold,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getText() => slide.title.split(' ').last == 'FruitHUB'
      ? RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: slide.title.substring(0, slide.title.length - 8),
                style: AppTextStyles.font22color0C0D0DBold,
              ),
              TextSpan(text: 'Fruit', style: AppTextStyles.font22color1B5E37Bold),
              TextSpan(text: 'HUB', style: AppTextStyles.font22colorF4A91FBold),
            ],
          ),
        )
      : Text(slide.title, style: AppTextStyles.font22color0C0D0DBold);
}
