import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/widgets/custom_empty_state_widget.dart';

class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 85.h),
    child: CustomEmptyStateWidget(
      customIcon: Container(
        width: 100.w,
        height: 100.h,
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.shopping_cart_outlined,
            size: 48.r,
            color: context.colors.primary,
          ),
        ),
      ),
      title: AppStrings.shoppingCart,
      text: AppStrings.emptyCartSubtitle,
    ),
  );
}
