import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';

class AnimatedSplashView extends StatelessWidget {
  const AnimatedSplashView({super.key});

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
              height: 300,
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
