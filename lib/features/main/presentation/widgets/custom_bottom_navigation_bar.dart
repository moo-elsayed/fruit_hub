import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/features/main/presentation/items/custom_bottom_navigation_item_params.dart';
import 'package:fruit_hub/features/main/presentation/items/nav_bar_item.dart';
import 'package:fruit_hub/features/main/presentation/widgets/custom_bottom_navigation_bar_item_widget.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final List<NavBarItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.only(bottom: 16.h, left: 14.w, right: 14.w),
      color: Colors.transparent,
      child: Container(
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            items.length,
            (index) => CustomBottomNavigationItemWidget(
              params: CustomBottomNavigationItemParams(
                isSelected: currentIndex == index,
                icon: items[index].icon,
                activeIcon: items[index].activeIcon,
                label: items[index].label,
                onTap: () => onTabSelected(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
