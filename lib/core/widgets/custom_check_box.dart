import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import '../helpers/app_assets.dart';

class CustomCheckBox extends StatefulWidget {
  const CustomCheckBox({
    super.key,
    required this.onChanged,
    this.value = false,
  });

  final ValueChanged<bool> onChanged;
  final bool value;

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  late bool _myBool;

  @override
  void initState() {
    super.initState();
    _myBool = widget.value;
  }

  @override
  void didUpdateWidget(CustomCheckBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _myBool = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      setState(() {
        _myBool = !_myBool;
        widget.onChanged(_myBool);
      });
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: 24.w,
      height: 24.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: !_myBool ? context.colors.border : context.colors.primary,
          width: 1.5,
        ),
        color: _myBool ? context.colors.primary : context.colors.surface,
      ),
      child: _myBool
          ? Center(
              child: SvgPicture.asset(
                AppAssets.iconsCheck,
                width: 16.w,
                height: 16.h,
              ),
            )
          : null,
    ),
  );
}
