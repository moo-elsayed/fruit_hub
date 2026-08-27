import 'package:flutter/material.dart';

class CustomBottomNavigationItemParams {
  const CustomBottomNavigationItemParams({
    required this.isSelected,
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.onTap,
  });

  final bool isSelected;
  final String icon;
  final String? activeIcon;
  final String label;
  final VoidCallback onTap;
}
