import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class ProfileCardItem {
  const ProfileCardItem({
    required this.icon,
    required this.title,
    this.trailingText,
    this.trailingWidget,
    this.showArrow = true,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? trailingText;
  final Widget? trailingWidget;
  final bool showArrow;
  final VoidCallback? onTap;
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.items});

  final List<ProfileCardItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: context.isDarkMode
              ? colors.border.withValues(alpha: 0.5)
              : colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: _getBorderRadius(index, items.length),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          item.icon,
                          color: colors.primary,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.font14Medium.copyWith(
                            color: colors.mainText,
                          ),
                        ),
                      ),
                      if (item.trailingText != null) ...[
                        Text(
                          item.trailingText!,
                          style: AppTextStyles.font13Regular.copyWith(
                            color: colors.subText,
                          ),
                        ),
                        SizedBox(width: 6.w),
                      ],
                      if (item.trailingWidget != null) item.trailingWidget!,
                      if (item.showArrow)
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: colors.subText,
                          size: 14.sp,
                        ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.border.withValues(alpha: 0.2),
                  indent: 50.w,
                  endIndent: 16.w,
                ),
            ],
          );
        }),
      ),
    );
  }

  BorderRadius _getBorderRadius(int index, int total) {
    if (total == 1) return BorderRadius.circular(16.r);
    if (index == 0) {
      return BorderRadius.vertical(top: Radius.circular(16.r));
    }
    if (index == total - 1) {
      return BorderRadius.vertical(bottom: Radius.circular(16.r));
    }
    return BorderRadius.zero;
  }
}
