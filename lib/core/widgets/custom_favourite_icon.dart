import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

class CustomFavouriteIcon extends StatefulWidget {
  const CustomFavouriteIcon({
    super.key,
    required this.isFavourite,
    required this.onChanged,
    this.size,
    this.iconSize,
    this.backgroundColor,
  });

  final bool isFavourite;
  final VoidCallback onChanged;
  final double? size;
  final double? iconSize;
  final Color? backgroundColor;

  @override
  State<CustomFavouriteIcon> createState() => _CustomFavouriteIconState();
}

class _CustomFavouriteIconState extends State<CustomFavouriteIcon> {
  late bool _isFavourite = widget.isFavourite;

  @override
  void didUpdateWidget(CustomFavouriteIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavourite != oldWidget.isFavourite) {
      _isFavourite = widget.isFavourite;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double buttonSize = widget.size ?? 24.r;
    final double iconDimension =
        widget.iconSize ?? (buttonSize * 0.55).roundToDouble();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _isFavourite = !_isFavourite);
        widget.onChanged();
      },
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              widget.backgroundColor ??
              context.colors.surface.withValues(alpha: 0.9),
          border: Border.all(color: context.colors.border, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: context.colors.mainText.withValues(alpha: 0.04),
              blurRadius: 6.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: Tween<double>(
              begin: 0.7,
              end: 1.0,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: _isFavourite
              ? Icon(
                  CupertinoIcons.heart_fill,
                  key: const ValueKey('filled'),
                  color: context.colors.error,
                  size: iconDimension,
                )
              : Icon(
                  CupertinoIcons.heart,
                  key: const ValueKey('outlined'),
                  color: context.colors.mainText,
                  size: iconDimension,
                ),
        ),
      ),
    );
  }
}
