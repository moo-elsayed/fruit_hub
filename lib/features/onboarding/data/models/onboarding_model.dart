import 'package:easy_localization/easy_localization.dart';
import '../../../../generated/assets.dart';

class OnboardingModel {
  OnboardingModel({
    required this.backgroundImage,
    required this.image,
    required this.title,
    required this.description,
  });

  final String backgroundImage;
  final String image;
  final String title;
  final String description;

  static List<OnboardingModel> slides = [
    OnboardingModel(
      backgroundImage: Assets.svgsPageViewItem1BackgroundImage,
      image: Assets.svgsPageViewItem1Image,
      title: "page_view_item1_title".tr(),
      description: "page_view_item1_description".tr(),
    ),
    OnboardingModel(
      backgroundImage: Assets.svgsPageViewItem2BackgroundImage,
      image: Assets.svgsPageViewItem2Image,
      title: "page_view_item2_title".tr(),
      description: "page_view_item2_description".tr(),
    ),
  ];
}
