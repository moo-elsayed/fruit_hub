import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

class SortOptionItem extends StatelessWidget {
  const SortOptionItem({
    super.key,
    required this.onTap,
    required this.isSelected,
    required this.title,
  });

  final VoidCallback onTap;
  final bool isSelected;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: .symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.color1B5E37.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: .circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.color1B5E37 : AppColors.colorF3F5F7,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: isSelected
                    ? AppTextStyles.font13color1B5E37Bold
                    : AppTextStyles.font13GreyShade700Medium,
              ),
            ),
            Container(
              height: 20.h,
              width: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.color1B5E37
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: isSelected
                  ? Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.color1B5E37,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
