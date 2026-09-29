import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/enums/product_category_filter.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class ProductCategoryFilterChip extends StatelessWidget {
  const ProductCategoryFilterChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final ProductCategoryFilter category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isSelected ? context.colors.primary : context.colors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isSelected ? context.colors.primary : context.colors.border,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        category.label,
        style: isSelected
            ? AppTextStyles.font13Bold.copyWith(color: AppPalette.white)
            : AppTextStyles.font13Medium.copyWith(
                color: context.colors.bodyText,
              ),
      ),
    ),
  );
}
