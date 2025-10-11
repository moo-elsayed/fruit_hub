import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/app_section/domain/entities/bottom_navigation_bar_entity.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_colors.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key, required this.onItemTapped});

  final ValueChanged<int> onItemTapped;

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    _selectedIndex = index;
    widget.onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 27.w, vertical: 20.h),
      decoration: const ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        shadows: [
          BoxShadow(
            color: AppColors.bottomNavigationBarShadowColor,
            blurRadius: 7,
            offset: Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: bottomNavigationBarItems.map((entity) {
          var index = bottomNavigationBarItems.indexWhere(
            (element) => element.label == entity.label,
          );
          return GestureDetector(
            onTap: () => _onItemTapped(index),
            child: _buildBottomNavigationBarItem(
              entity: entity,
              active: index == _selectedIndex,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomNavigationBarItem({
    required BottomNavigationBarEntity entity,
    required bool active,
  }) {
    return !active
        ? _buildIcon(iconPath: entity.outlineIcon)
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: AppColors.colorF3F5F7,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15.r,
                  backgroundColor: AppColors.color1B5E37,
                  child: SvgPicture.asset(
                    entity.filledIcon,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                Gap(4.w),
                Text(
                  entity.label,
                  style: AppTextStyles.font11color1B5E37semiBold,
                ),
                Gap(7.w),
              ],
            ),
          );
  }

  SvgPicture _buildIcon({bool active = false, required String iconPath}) {
    return SvgPicture.asset(
      iconPath,
      colorFilter: ColorFilter.mode(
        active ? AppColors.color1B5E37 : AppColors.color4E5556,
        BlendMode.srcIn,
      ),
    );
  }
}
