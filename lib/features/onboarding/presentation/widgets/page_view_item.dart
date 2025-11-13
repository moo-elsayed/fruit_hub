import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/extentions.dart';
import 'package:fruit_hub/features/onboarding/presentation/managers/onboarding_cubit/onboarding_cubit.dart';
import 'package:gap/gap.dart';
import '../../../../core/helpers/functions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/onboarding_entity.dart';

class PageViewItem extends StatelessWidget {
  const PageViewItem({super.key, required this.slide, required this.showSkip});

  final OnboardingEntity slide;
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
                right: isArabic(context) ? 20.w : null,
                left: !isArabic(context) ? 20.w : null,
                child: BlocListener<OnboardingCubit, OnboardingState>(
                  listener: (context, state) {
                    if (state is OnboardingNavigateToHome) {
                      context.pushReplacementNamed(Routes.loginView);
                    }
                  },
                  child: GestureDetector(
                    onTap: () =>
                        context.read<OnboardingCubit>().setFirstTime(false),
                    child: Text(
                      "skip".tr(),
                      style: AppTextStyles.font13color949D9ERegular,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: EdgeInsetsGeometry.only(right: 37.w, left: 37.w, top: 64.h),
          child: Column(
            children: [
              _getTitle(),
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

  Widget _getTitle() => slide.title.split(' ').last == 'FruitHUB'
      ? RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: slide.title.substring(0, slide.title.length - 8),
                style: AppTextStyles.font22color0C0D0DBold,
              ),
              TextSpan(
                text: 'Fruit',
                style: AppTextStyles.font22color1B5E37Bold,
              ),
              TextSpan(text: 'HUB', style: AppTextStyles.font22colorF4A91FBold),
            ],
          ),
        )
      : Text(slide.title, style: AppTextStyles.font22color0C0D0DBold);
}
