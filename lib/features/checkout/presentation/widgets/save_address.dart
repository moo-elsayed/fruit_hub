import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

import '../../../../core/theming/app_text_styles.dart';

class SaveAddress extends StatefulWidget {
  const SaveAddress({super.key, required this.onChanged, this.value = true});

  final ValueChanged<bool> onChanged;
  final bool value;

  @override
  State<SaveAddress> createState() => _SaveAddressState();
}

class _SaveAddressState extends State<SaveAddress> {
  late final ValueNotifier<bool> _isSavedNotifier;

  @override
  void initState() {
    super.initState();
    _isSavedNotifier = ValueNotifier(widget.value);
  }

  @override
  void didUpdateWidget(SaveAddress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _isSavedNotifier.value = widget.value;
    }
  }

  @override
  void dispose() {
    _isSavedNotifier.dispose();
    super.dispose();
  }

  void _toggle() {
    final newValue = !_isSavedNotifier.value;
    _isSavedNotifier.value = newValue;
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: _toggle,
    child: ValueListenableBuilder<bool>(
      valueListenable: _isSavedNotifier,
      builder: (context, isSaved, _) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8.w,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: !isSaved
                    ? context.colors.border
                    : context.colors.primary,
                width: 1.5,
              ),
              color: isSaved ? context.colors.primary : context.colors.surface,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSaved
                  ? SvgPicture.asset(
                      AppAssets.iconsCheck,
                      key: const ValueKey('check'),
                      width: 16.w,
                      height: 16.h,
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),
          Text(
            AppStrings.saveAddress,
            style: AppTextStyles.font13SemiBold.copyWith(
              color: isSaved ? context.colors.mainText : context.colors.subText,
            ),
          ),
        ],
      ),
    ),
  );
}
