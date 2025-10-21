import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extentions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/onboarding/domain/entities/onboarding_model.dart';
import 'package:gap/gap.dart';
import '../../../../core/helpers/shared_preferences_manager.dart';
import '../widgets/onboarding_indicator.dart';
import '../widgets/onboarding_page_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  List<OnboardingEntity> slides = onboardingSlides;
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          OnboardingPageView(
            slides: slides,
            onPageChanged: (index) => setState(() => currentIndex = index),
          ),
          OnboardingIndicator(
            length: slides.length,
            currentIndex: currentIndex,
          ),
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
                child: CustomMaterialButton(
                  onPressed: () {
                    SharedPreferencesManager.setFirstTime(false);
                    context.pushReplacementNamed(Routes.loginView);
                  },
                  maxWidth: true,
                  text: "start_now".tr(),
                  textStyle: AppTextStyles.font16WhiteBold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
