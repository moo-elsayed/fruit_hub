import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/theming/app_colors.dart';

class CustomFavouriteIcon extends StatefulWidget {
  const CustomFavouriteIcon({
    super.key,
    required this.isFavourite,
    required this.onChanged,
  });

  final bool isFavourite;
  final Function() onChanged;

  @override
  State<CustomFavouriteIcon> createState() => _CustomFavouriteIconState();
}

class _CustomFavouriteIconState extends State<CustomFavouriteIcon> {
  late bool _isFavourite = widget.isFavourite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      width: 30.w,
      child: IconButton(
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          iconSize: 20.r,
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashRadius: 24,
        onPressed: () {
          setState(() => _isFavourite = !_isFavourite);
          widget.onChanged();
        },
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: Tween<double>(
              begin: 0.7,
              end: 1.0,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: _isFavourite
              ? const Icon(
                  CupertinoIcons.heart_fill,
                  key: ValueKey("filled"),
                  color: Colors.red,
                )
              : const Icon(
                  CupertinoIcons.heart,
                  key: ValueKey("outlined"),
                  color: AppColors.color292D32,
                ),
        ),
      ),
    );
  }
}
