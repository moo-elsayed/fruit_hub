import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/main/presentation/items/custom_bottom_navigation_item_params.dart';
import 'package:gap/gap.dart';

class CustomBottomNavigationItemWidget extends StatefulWidget {
  const CustomBottomNavigationItemWidget({super.key, required this.params});

  final CustomBottomNavigationItemParams params;

  @override
  State<CustomBottomNavigationItemWidget> createState() =>
      _CustomBottomNavigationItemWidgetState();
}

class _CustomBottomNavigationItemWidgetState
    extends State<CustomBottomNavigationItemWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _rotationAnimation = CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOutBack,
    );
    if (widget.params.isSelected) {
      _rotationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavigationItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.params.isSelected && widget.params.isSelected) {
      _rotationController.forward(from: 0.0);
    } else if (oldWidget.params.isSelected && !widget.params.isSelected) {
      _rotationController.reset();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSelected = widget.params.isSelected;
    final iconPath = (isSelected && widget.params.activeIcon != null)
        ? widget.params.activeIcon!
        : widget.params.icon;

    return InkWell(
      onTap: widget.params.onTap,
      borderRadius: BorderRadius.circular(30.r),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12.w : 8.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colors.primary : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: RotationTransition(
                turns: _rotationAnimation,
                child: SvgPicture.asset(
                  iconPath,
                  colorFilter: ColorFilter.mode(
                    isSelected ? AppPalette.white : colors.subText,
                    BlendMode.srcIn,
                  ),
                  height: 18.h,
                  width: 18.w,
                ),
              ),
            ),
            if (isSelected) ...[
              Gap(6.w),
              Text(
                widget.params.label,
                style: AppTextStyles.font12Bold.copyWith(color: colors.primary),
              ),
              Gap(4.w),
            ],
          ],
        ),
      ),
    );
  }
}
