import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/features/app_section/presentation/views/app_section.dart';
import 'package:fruit_hub/features/auth/presentation/views/login_view.dart';
import 'package:fruit_hub/features/splash_view/presentation/managers/splash_cubit/splash_cubit.dart';
import '../../../../generated/assets.dart';
import '../../../onboarding/presentation/views/onboarding_view.dart';

class AnimatedSplashViewBody extends StatefulWidget {
  const AnimatedSplashViewBody({super.key});

  @override
  State<AnimatedSplashViewBody> createState() => _AnimatedSplashViewBodyState();
}

class _AnimatedSplashViewBodyState extends State<AnimatedSplashViewBody> {
  void navigate(Widget view) => Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => view,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
    ),
  );

  @override
  void initState() {
    super.initState();
    context.read<SplashCubit>().checkAppStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToHome) {
          navigate(const AppSection());
        } else if (state is SplashNavigateToLogin) {
          navigate(const LoginView());
        } else if (state is SplashNavigateToOnboarding) {
          navigate(const OnboardingView());
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 1000),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SvgPicture.asset(Assets.svgsPlant),
            ),
          ),
          BounceInDown(
            duration: const Duration(milliseconds: 1200),
            child: Image.asset(
              'assets/images/splash_android_12.png',
              height: 300.h,
            ),
          ),
          FadeInUp(
            duration: const Duration(milliseconds: 1000),
            child: SvgPicture.asset(Assets.svgsSplashBottom),
          ),
        ],
      ),
    );
  }
}
