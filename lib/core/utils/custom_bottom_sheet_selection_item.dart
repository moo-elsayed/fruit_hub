import 'package:flutter/material.dart';

class CustomBottomSheetSelectionItem<T> {
  const CustomBottomSheetSelectionItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.value,
    this.isSelected,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final T? value;
  final bool? isSelected;
  final VoidCallback onTap;
}
