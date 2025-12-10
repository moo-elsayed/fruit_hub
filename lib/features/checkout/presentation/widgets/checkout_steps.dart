import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_step_item.dart';

class CheckoutSteps extends StatelessWidget {
  const CheckoutSteps({
    super.key,
    required this.currentIndex,
    required this.steps,
    required this.pageController,
  });

  final int currentIndex;
  final List<String> steps;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 23.h,
      child: Row(
        mainAxisAlignment: .spaceAround,
        children: List.generate(
          steps.length,
          (index) => GestureDetector(
            onTap: () {
              if (index < currentIndex) {
                pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: CustomStepItem(
              isActive: index <= currentIndex,
              stepNumber: index + 1,
              stepText: steps[index],
            ),
          ),
        ),
      ),
    );
  }
}
