import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:gap/gap.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_material_button.dart';
import '../../domain/entities/onboarding_entity.dart';
import '../managers/onboarding_cubit/onboarding_cubit.dart';
import 'onboarding_indicator.dart';
import 'onboarding_page_view.dart';

class OnboardingViewBody extends StatefulWidget {
  const OnboardingViewBody({super.key});

  @override
  State<OnboardingViewBody> createState() => _OnboardingViewBodyState();
}

class _OnboardingViewBodyState extends State<OnboardingViewBody> {
  List<OnboardingEntity> slides = onboardingSlides;
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OnboardingPageView(
          slides: slides,
          onPageChanged: (index) => setState(() => currentIndex = index),
        ),
        OnboardingIndicator(length: slides.length, currentIndex: currentIndex),
        Visibility(
          visible: currentIndex == slides.length - 1,
          replacement: Gap(121.h),
          child: Padding(
            padding: EdgeInsetsGeometry.only(
              top: 29.h,
              bottom: 43.h,
              right: 16.w,
              left: 16.w,
            ),
            child: FadeInUp(
              duration: const Duration(milliseconds: 500),
              from: 50,
              child: BlocListener<OnboardingCubit, OnboardingState>(
                listener: (context, state) {
                  if (state is OnboardingNavigateToHome) {
                    context.pushReplacementNamed(Routes.loginView);
                  }
                },
                child: CustomMaterialButton(
                  onPressed: () {
                    context.read<OnboardingCubit>().setFirstTime(false);
                  },
                  maxWidth: true,
                  text: "start_now".tr(),
                  textStyle: AppTextStyles.font16WhiteBold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
