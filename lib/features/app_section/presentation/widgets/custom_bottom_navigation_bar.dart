import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/features/app_section/domain/entities/bottom_navigation_bar_entity.dart';
import 'package:fruit_hub/features/app_section/presentation/widgets/custom_bottom_navigation_bar_item.dart';
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
      padding: EdgeInsetsGeometry.symmetric(horizontal: 27.w),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
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
        children: bottomNavigationBarItems.asMap().entries.map((entry) {
          final index = entry.key;
          final entity = entry.value;
          return CustomBottomNavigationItem(
            onTap: () => _onItemTapped(index),
            entity: entity,
            active: index == _selectedIndex,
          );
        }).toList(),
      ),
    );
  }
}
