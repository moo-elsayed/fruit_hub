import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:fruit_hub/features/onboarding/presentation/managers/onboarding_cubit/onboarding_cubit.dart';
import 'package:gap/gap.dart';

import 'onboarding_item_title.dart';

class PageViewItem extends StatelessWidget {
  const PageViewItem({super.key, required this.slide, required this.showSkip});

  final OnboardingEntity slide;
  final bool showSkip;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SvgPicture.asset(slide.backgroundImage, fit: BoxFit.fill),
          SvgPicture.asset(slide.image),
          if (showSkip)
            Positioned(
              top: 60.h,
              right: context.isArabic ? 20.w : null,
              left: !context.isArabic ? 20.w : null,
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
                    AppStrings.skip,
                    style: AppTextStyles.font14SemiBold.copyWith(
                      color: AppPalette.textBodyLight,
                    ),
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
            OnboardingItemTitle(title: slide.title),
            Gap(24.h),
            Text(
              slide.description,
              textAlign: TextAlign.center,
              style: AppTextStyles.font13SemiBold.copyWith(
                color: context.colors.bodyText,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
