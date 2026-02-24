import 'package:flutter/material.dart';
import 'package:fruit_hub/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:fruit_hub/features/onboarding/presentation/widgets/page_view_item.dart';

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({
    super.key,
    required this.slides,
    this.onPageChanged,
  });

  final List<OnboardingEntity> slides;
  final void Function(int)? onPageChanged;

  @override
  Widget build(BuildContext context) => Expanded(
    child: PageView.builder(
      itemCount: slides.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) => PageViewItem(
        slide: slides[index],
        showSkip: index != slides.length - 1,
      ),
    ),
  );
}
