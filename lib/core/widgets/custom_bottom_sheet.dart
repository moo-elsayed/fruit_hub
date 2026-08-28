import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/utils/custom_bottom_sheet_selection_item.dart';
import 'package:fruit_hub/core/widgets/custom_bottom_sheet_handle.dart';
import 'package:gap/gap.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.items,
  });

  final String title;
  final String? subtitle;
  final List<CustomBottomSheetSelectionItem> items;

  static void show({
    required BuildContext context,
    required String title,
    String? subtitle,
    required List<CustomBottomSheetSelectionItem> items,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (context) =>
          CustomBottomSheet(title: title, subtitle: subtitle, items: items),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: context.isDarkMode
              ? colors.border.withValues(alpha: 0.5)
              : colors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const BottomSheetHandle(),
          Gap(12.h),

          // Title
          Text(
            title,
            style: AppTextStyles.font16Bold.copyWith(color: colors.mainText),
            textAlign: TextAlign.center,
          ),

          // Subtitle (Optional)
          if (subtitle != null) ...[
            Gap(4.h),
            Text(
              subtitle!,
              style: AppTextStyles.font13Regular.copyWith(
                color: colors.subText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          Gap(20.h),

          // Selection items list
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isLast = index == items.length - 1;

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
                    child: InkWell(
                      onTap: () {
                        context.pop();
                        item.onTap();
                      },
                      borderRadius: BorderRadius.circular(14.r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: item.isSelected
                              ? colors.primary.withValues(alpha: 0.12)
                              : (context.isDarkMode
                                    ? colors.border.withValues(alpha: 0.2)
                                    : colors.border.withValues(alpha: 0.12)),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: item.isSelected
                                ? colors.primary
                                : colors.border,
                            width: item.isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (item.icon != null) ...[
                              Container(
                                padding: EdgeInsets.all(6.r),
                                decoration: BoxDecoration(
                                  color: item.isSelected
                                      ? colors.primary.withValues(alpha: 0.15)
                                      : colors.primary.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.icon,
                                  color: item.isSelected
                                      ? colors.primary
                                      : colors.mainText,
                                  size: 18.sp,
                                ),
                              ),
                              Gap(12.w),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: AppTextStyles.font14Medium.copyWith(
                                      color: item.isSelected
                                          ? colors.primary
                                          : colors.mainText,
                                      fontWeight: item.isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                    ),
                                  ),
                                  if (item.subtitle != null) ...[
                                    Gap(2.h),
                                    Text(
                                      item.subtitle!,
                                      style: AppTextStyles.font12Regular
                                          .copyWith(color: colors.subText),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Gap(8.w),
                            Icon(
                              item.isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: item.isSelected
                                  ? colors.primary
                                  : colors.subText,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
