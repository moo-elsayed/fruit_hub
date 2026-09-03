import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_check_box.dart';

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
          IgnorePointer(
            child: CustomCheckBox(onChanged: (_) {}, value: isSaved),
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
