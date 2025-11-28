import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_step_item.dart';

class CheckoutSteps extends StatelessWidget {
  const CheckoutSteps({
    super.key,
    required this.currentIndex,
    required this.steps,
  });

  final int currentIndex;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 23.h,
      child: Row(
        mainAxisAlignment: .spaceAround,
        children: List.generate(
          steps.length,
          (index) => CustomStepItem(
            isActive: index <= currentIndex,
            stepNumber: index + 1,
            stepText: steps[index],
          ),
        ),
      ),
    );
  }
}
