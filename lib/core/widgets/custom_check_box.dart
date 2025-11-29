import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../theming/app_colors.dart';
import '../../generated/assets.dart';

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
  Widget build(BuildContext context) {
    return GestureDetector(
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
            color: !_myBool ? AppColors.colorDDDFDF : AppColors.color1B5E37,
            width: 1.5,
          ),
          color: _myBool ? AppColors.color1B5E37 : Colors.white,
        ),
        child: _myBool
            ? Center(
                child: SvgPicture.asset(
                  Assets.iconsCheck,
                  width: 16.w,
                  height: 16.h,
                ),
              )
            : null,
      ),
    );
  }
}
