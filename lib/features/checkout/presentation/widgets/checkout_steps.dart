import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'custom_step_item.dart';

class CheckoutSteps extends StatelessWidget {
  const CheckoutSteps({super.key, required this.currentIndex});

  final int currentIndex;

  List<String> get steps => [
    "shipping".tr(),
    "address".tr(),
    "payment".tr(),
    "review".tr(),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceAround,
      children: List.generate(
        steps.length,
        (index) => CustomStepItem(
          isActive: index <= currentIndex,
          stepNumber: index + 1,
          step: steps[index],
        ),
      ),
    );
  }
}
