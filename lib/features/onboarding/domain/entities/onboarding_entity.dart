import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';

class OnboardingEntity {
  const OnboardingEntity({
    required this.title,
    required this.description,
    required this.image,
    required this.backgroundImage,
  });

  final String title;
  final String description;
  final String image;
  final String backgroundImage;
}

List<OnboardingEntity> get onboardingSlides => [
  OnboardingEntity(
    backgroundImage: AppAssets.svgsPageViewItem1BackgroundImage,
    image: AppAssets.svgsPageViewItem1Image,
    title: AppStrings.pageViewItem1Title,
    description: AppStrings.pageViewItem1Description,
  ),
  OnboardingEntity(
    backgroundImage: AppAssets.svgsPageViewItem2BackgroundImage,
    image: AppAssets.svgsPageViewItem2Image,
    title: AppStrings.pageViewItem2Title,
    description: AppStrings.pageViewItem2Description,
  ),
];
