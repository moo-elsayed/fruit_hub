import 'package:easy_localization/easy_localization.dart';
import '../../../../generated/assets.dart';

class OnboardingEntity {
  OnboardingEntity({
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
    backgroundImage: Assets.svgsPageViewItem1BackgroundImage,
    image: Assets.svgsPageViewItem1Image,
    title: "page_view_item1_title".tr(),
    description: "page_view_item1_description".tr(),
  ),
  OnboardingEntity(
    backgroundImage: Assets.svgsPageViewItem2BackgroundImage,
    image: Assets.svgsPageViewItem2Image,
    title: "page_view_item2_title".tr(),
    description: "page_view_item2_description".tr(),
  ),
];
