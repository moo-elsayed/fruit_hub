import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import '../../../../core/helpers/app_assets.dart';
import '../managers/splash_cubit/splash_cubit.dart';

class AnimatedSplashViewBody extends StatefulWidget {
  const AnimatedSplashViewBody({super.key});

  @override
  State<AnimatedSplashViewBody> createState() => _AnimatedSplashViewBodyState();
}

class _AnimatedSplashViewBodyState extends State<AnimatedSplashViewBody> {
  @override
  void initState() {
    super.initState();
    context.read<SplashCubit>().checkAppStatus();
  }

  @override
  Widget build(BuildContext context) => BlocListener<SplashCubit, SplashState>(
    listener: (context, state) {
      if (state is SplashNavigationState) {
        switch (state.navigation) {
          case SplashNavigation.home:
            context.pushReplacementNamed(Routes.appSection);
          case SplashNavigation.login:
            context.pushReplacementNamed(Routes.loginView);
          case SplashNavigation.onboarding:
            context.pushReplacementNamed(Routes.onboardingView);
        }
      }
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 1000),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(AppAssets.svgsPlant),
          ),
        ),
        BounceInDown(
          duration: const Duration(milliseconds: 1200),
          child: Image.asset(
            context.isDarkMode
                ? AppAssets.imagesSplashAndroid12Dark
                : AppAssets.imagesSplashAndroid12,
            height: 300.h,
          ),
        ),
        FadeInUp(
          duration: const Duration(milliseconds: 1000),
          child: SvgPicture.asset(AppAssets.svgsSplashBottom),
        ),
      ],
    ),
  );
}
