import 'package:flutter/material.dart';
import 'package:fruit_hub/core/enums/step_item_state.dart';

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
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: List.generate(
      steps.length,
      (index) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (index < currentIndex) {
            onStepTapped?.call(index);
          }
        },
        child: CustomStepItem(
          state: StepItemState.fromIndex(
            index: index,
            currentIndex: currentIndex,
          ),
          stepNumber: index + 1,
          stepText: steps[index],
        ),
      ),
    ),
  );
}
