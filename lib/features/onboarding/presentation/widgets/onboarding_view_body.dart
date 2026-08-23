import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:fruit_hub/features/onboarding/presentation/managers/onboarding_cubit/onboarding_cubit.dart';
import 'package:gap/gap.dart';
import 'onboarding_indicator.dart';
import 'onboarding_page_view.dart';

class OnboardingViewBody extends StatefulWidget {
  const OnboardingViewBody({super.key});

  @override
  State<OnboardingViewBody> createState() => _OnboardingViewBodyState();
}

class _OnboardingViewBodyState extends State<OnboardingViewBody> {
  final List<OnboardingEntity> _slides = onboardingSlides;
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _currentIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      OnboardingPageView(
        slides: _slides,
        onPageChanged: (index) => _currentIndexNotifier.value = index,
      ),
      ValueListenableBuilder<int>(
        valueListenable: _currentIndexNotifier,
        builder: (context, currentIndex, _) => Column(
          children: [
            OnboardingIndicator(
              length: _slides.length,
              currentIndex: currentIndex,
            ),
            Visibility(
              visible: currentIndex == _slides.length - 1,
              replacement: Gap(121.h),
              child: Padding(
                padding: EdgeInsets.only(
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
                      onPressed: () =>
                          context.read<OnboardingCubit>().setFirstTime(false),
                      maxWidth: true,
                      text: AppStrings.startNow,
                      textStyle: AppTextStyles.font16Bold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
