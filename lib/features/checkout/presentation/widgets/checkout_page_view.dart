import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/features/checkout/presentation/args/address_args.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_review_body.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/payment_body.dart';

import 'address_body.dart';

class CheckoutPageView extends StatelessWidget {
  const CheckoutPageView({
    super.key,
    this.onPageChanged,
    required this.pageController,
    required this.addressArgs,
  });

  final void Function(int)? onPageChanged;
  final PageController pageController;
  final AddressArgs addressArgs;

  @override
  Widget build(BuildContext context) => Expanded(
    child: PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: pageController,
      onPageChanged: onPageChanged,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: AddressBody(addressArgs: addressArgs),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: const PaymentBody(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: OrderReviewBody(
            onEditStep: (pageIndex) => pageController.animateToPage(
              pageIndex,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
          ),
        ),
      ],
    ),
  );
}
