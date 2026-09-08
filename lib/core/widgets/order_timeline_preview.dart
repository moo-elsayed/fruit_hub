import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/enums/step_item_state.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';

import '../../features/checkout/presentation/widgets/order_timeline_connector.dart';
import '../../features/checkout/presentation/widgets/order_timeline_step_item.dart';

class OrderTimelinePreview extends StatelessWidget {
  const OrderTimelinePreview({super.key, this.currentStep = 1});

  final int currentStep;

  static final List<(String, IconData)> _steps = [
    (AppStrings.orderPlaced, Icons.check_circle_rounded),
    (AppStrings.orderPreparing, Icons.soup_kitchen_outlined),
    (AppStrings.orderOnTheWay, Icons.delivery_dining_outlined),
    (AppStrings.orderDelivered, Icons.home_outlined),
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: context.isDarkMode
          ? context.colors.surface
          : AppPalette.bgLightSecondary,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: context.colors.border),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(_steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final prevIndex = index ~/ 2;
          return OrderTimelineConnector(isCompleted: prevIndex < currentStep);
        }

        final stepIndex = index ~/ 2;
        final (title, icon) = _steps[stepIndex];

        return OrderTimelineStepItem(
          title: title,
          icon: icon,
          state: StepItemState.fromIndex(
            index: stepIndex,
            currentIndex: currentStep,
          ),
        );
      }),
    ),
  );
}
