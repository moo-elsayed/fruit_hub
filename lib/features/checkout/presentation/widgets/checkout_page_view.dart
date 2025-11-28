import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/features/checkout/presentation/args/address_args.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/payment_body.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/review_body.dart';
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

  List<Widget> get pageViews => [
    AddressBody(addressArgs: addressArgs),
    const PaymentBody(),
    ReviewBody(pageController: pageController),
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
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
