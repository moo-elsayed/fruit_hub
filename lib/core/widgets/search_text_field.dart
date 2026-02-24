import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../theming/app_colors.dart';
import '../theming/app_text_styles.dart';
import 'text_form_field_helper.dart';
import '../../generated/assets.dart';

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
  Widget build(BuildContext context) {
    return GestureDetector(
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
            Assets.iconsSearchIcon,
            fit: BoxFit.scaleDown,
          ),
          fillColor: AppColors.white,
          borderColor: AppColors.white,
          hint: "search_for".tr(),
          hintStyle: AppTextStyles.font13color949D9ERegular,
        ),
      ),
    );
  }
}
