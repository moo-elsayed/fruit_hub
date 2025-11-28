import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/payment_body.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/review_body.dart';
import 'address_body.dart';

class CheckoutPageView extends StatelessWidget {
  const CheckoutPageView({
    super.key,
    this.onPageChanged,
    required this.pageController,
  });

  final void Function(int)? onPageChanged;
  final PageController pageController;

  List<Widget> get pageViews => [
    const AddressBody(),
    const PaymentBody(),
    const ReviewBody(),
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PageView.builder(
        controller: pageController,
        itemCount: pageViews.length,
        onPageChanged: onPageChanged,
        itemBuilder: (context, index) {
          return Padding(
            padding: .symmetric(horizontal: 16.w),
            child: pageViews[index],
          );
        },
      ),
    );
  }
}
