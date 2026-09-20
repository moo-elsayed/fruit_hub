import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/text_form_field_helper.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onClear,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.suffixWidget,
    this.hint,
  });

  final TextEditingController? controller;
  final void Function(String?)? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final Widget? suffixWidget;
  final String? hint;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AppPalette.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormFieldHelper(
        focusNode: focusNode,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        controller: controller,
        onChanged: onChanged,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        prefixIcon: SvgPicture.asset(
          AppAssets.iconsSearchIcon,
          fit: BoxFit.scaleDown,
        ),
        suffixWidget:
            suffixWidget ??
            (controller != null
                ? _SearchClearSuffix(
                    controller: controller!,
                    onClear: () {
                      controller?.clear();
                      onChanged?.call('');
                      onClear?.call();
                    },
                  )
                : null),
        fillColor: context.colors.surface,
        borderColor: context.colors.border.withValues(alpha: 0.6),
        hint: hint ?? AppStrings.searchFor,
        hintStyle: AppTextStyles.font13Regular.copyWith(
          color: context.colors.subText,
        ),
      ),
    ),
  );
}

class _SearchClearSuffix extends StatelessWidget {
  const _SearchClearSuffix({required this.controller, required this.onClear});

  final TextEditingController controller;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          if (value.text.isEmpty) return const SizedBox.shrink();
          return GestureDetector(
            onTap: onClear,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Icon(
                Icons.close_rounded,
                color: context.colors.subText,
                size: 20.sp,
              ),
            ),
          );
        },
      );
}

// Alias for backwards compatibility
typedef SearchTextFiled = SearchTextField;
