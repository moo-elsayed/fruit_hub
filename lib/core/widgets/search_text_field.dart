import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import '../helpers/app_assets.dart';
import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';
import 'text_form_field_helper.dart';

class SearchTextFiled extends StatelessWidget {
  const SearchTextFiled({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.enabled = true,
    this.focusNode,
  });

  final TextEditingController? controller;
  final void Function(String?)? onChanged;
  final VoidCallback? onTap;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 9,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextFormFieldHelper(
        focusNode: focusNode,
        enabled: enabled,
        controller: controller,
        onChanged: onChanged,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        prefixIcon: SvgPicture.asset(
          AppAssets.iconsSearchIcon,
          fit: BoxFit.scaleDown,
        ),
        fillColor: context.colors.surface,
        borderColor: context.colors.surface,
        hint: AppStrings.searchFor,
        hintStyle: AppTextStyles.font13Regular.copyWith(
          color: context.colors.subText,
        ),
      ),
    ),
  );
}
