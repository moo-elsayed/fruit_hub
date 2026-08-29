import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

class MainScreenHeader extends StatelessWidget {
  const MainScreenHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40.h,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.font20Bold.copyWith(
              color: context.colors.mainText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?action,
      ],
    ),
  );
}
