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

  List<Widget> get _pages => [
    AddressBody(addressArgs: addressArgs),
    const PaymentBody(),
    OrderReviewBody(
      onEditStep: (pageIndex) => pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) => Expanded(
    child: PageView.builder(
      physics: const NeverScrollableScrollPhysics(),
      controller: pageController,
      onPageChanged: onPageChanged,
      itemCount: _pages.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: _pages[index],
      ),
    ),
  );
}
