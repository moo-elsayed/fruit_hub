import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/interactive_rating_bar.dart';
import 'package:gap/gap.dart';

class AddReviewRatingSection extends StatelessWidget {
  const AddReviewRatingSection({super.key, required this.ratingNotifier});

  final ValueNotifier<int> ratingNotifier;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: ratingNotifier,
    builder: (context, currentStars, _) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InteractiveRatingBar(
          rating: currentStars,
          size: 38.sp,
          spacing: 8.w,
          onRatingChanged: (star) => ratingNotifier.value = star,
        ),
        Gap(10.h),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTextStyles.font14Bold.copyWith(
            color: AppPalette.getRatingColor(currentStars),
          ),
          child: Text(AppStrings.getRatingLabel(currentStars)),
        ),
      ],
    ),
  );
}
