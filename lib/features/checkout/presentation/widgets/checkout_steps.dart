import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/enums/step_item_state.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

import 'custom_step_item.dart';

class CheckoutSteps extends StatelessWidget {
  const CheckoutSteps({
    super.key,
    required this.currentIndex,
    required this.steps,
    this.onStepTapped,
  });

  final int currentIndex;
  final List<String> steps;
  final ValueChanged<int>? onStepTapped;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final lineIndex = index ~/ 2;
          final isLineCompleted = currentIndex > lineIndex;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 1.5.h,
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              decoration: BoxDecoration(
                color: isLineCompleted
                    ? context.colors.primary
                    : context.colors.border,
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
          );
        }

        final stepIndex = index ~/ 2;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (stepIndex < currentIndex) {
              onStepTapped?.call(stepIndex);
            }
          },
          child: CustomStepItem(
            state: StepItemState.fromIndex(
              index: stepIndex,
              currentIndex: currentIndex,
            ),
            stepNumber: stepIndex + 1,
            stepText: steps[stepIndex],
          ),
        );
      }),
    ),
  );
}
