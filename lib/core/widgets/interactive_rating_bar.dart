import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';

class InteractiveRatingBar extends StatelessWidget {
  const InteractiveRatingBar({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.size,
    this.activeColor,
    this.inactiveColor,
    this.spacing,
  });

  final int rating;
  final ValueChanged<int>? onRatingChanged;
  final double? size;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? spacing;

  Color _getActiveColor(int currentRating) =>
      activeColor ?? AppPalette.getRatingColor(currentRating);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (index) {
      final starIndex = index + 1;
      final isSelected = starIndex <= rating;
      final starSize = size ?? 32.sp;

      final starIcon = AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: isSelected ? 1.08 : 0.95,
        child: Icon(
          isSelected ? Icons.star_rounded : Icons.star_border_rounded,
          size: starSize,
          color: isSelected
              ? _getActiveColor(rating)
              : (inactiveColor ??
                    context.colors.subText.withValues(alpha: 0.35)),
        ),
      );

      if (onRatingChanged == null) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: (spacing ?? 3.w) / 2),
          child: starIcon,
        );
      }

      return GestureDetector(
        onTap: () => onRatingChanged!(starIndex),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: (spacing ?? 4.w) / 2),
          child: starIcon,
        ),
      );
    }),
  );
}
