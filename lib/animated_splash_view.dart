import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/features/onboarding/presentation/views/onboarding_view.dart';

class AnimatedSplashView extends StatefulWidget {
  const AnimatedSplashView({super.key});

  @override
  State<AnimatedSplashView> createState() => _AnimatedSplashViewState();
}

class _AnimatedSplashViewState extends State<AnimatedSplashView> {
  @override
  void initState() {
    super.initState();
    navigate();
  }

  void navigate() async {
    Future.delayed(const Duration(seconds: 2, milliseconds: 300), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingView(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 1000),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SvgPicture.asset(AppAssets.plant),
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
            child: SvgPicture.asset(AppAssets.splashBottom),
          ),
        ],
      ),
    );
  }
}
