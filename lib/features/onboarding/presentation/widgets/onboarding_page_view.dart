import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/theming/styles.dart';
import 'package:fruit_hub/features/onboarding/data/models/onboarding_model.dart';
import 'package:gap/gap.dart';

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({
    super.key,
    required this.slides,
    this.onPageChanged,
  });

  final List<OnboardingModel> slides;
  final void Function(int)? onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PageView.builder(
        itemCount: slides.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SvgPicture.asset(
                    slides[index].backgroundImage,
                    fit: BoxFit.fill,
                  ),
                  SvgPicture.asset(slides[index].image),
                  if (index == 0)
                    Positioned(
                      top: 60.h,
                      right: context.locale.languageCode == 'ar' ? 20.w : null,
                      left: context.locale.languageCode == 'en' ? 20.w : null,
                      child: Text(
                        "skip".tr(),
                        style: AppStyles.font13color949D9ERegular,
                      ),
                    ),
                ],
              ),
              Padding(
                padding: EdgeInsetsGeometry.only(
                  right: 37.w,
                  left: 37.w,
                  top: 64.h,
                ),
                child: Column(
                  children: [
                    Text(
                      slides[index].title,
                      style: AppStyles.font23color0C0D0DBold,
                    ),
                    Gap(24.h),
                    Text(
                      slides[index].description,
                      textAlign: TextAlign.center,
                      style: AppStyles.font13color4E5556FSemiBold,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        onPageChanged: onPageChanged,
      ),
    );
  }
}
