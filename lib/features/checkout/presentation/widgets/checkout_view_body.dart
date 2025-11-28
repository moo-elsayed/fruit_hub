import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../../core/entities/cart_item_entity.dart';
import '../args/address_args.dart';
import '../managers/checkout_cubit/checkout_cubit.dart';
import 'checkout_page_view.dart';
import 'checkout_steps.dart';

class CheckoutViewBody extends StatefulWidget {
  const CheckoutViewBody({
    super.key,
    this.onPageChanged,
    required this.pageController,
    required this.currentIndex,
    required this.steps,
    required this.cartItems,
    required this.addressArgs,
  });

  final List<CartItemEntity> cartItems;
  final void Function(int)? onPageChanged;
  final PageController pageController;
  final int currentIndex;
  final List<String> steps;
  final AddressArgs addressArgs;

  @override
  State<CheckoutViewBody> createState() => _CheckoutViewBodyState();
}

class _CheckoutViewBodyState extends State<CheckoutViewBody> {
  @override
  void initState() {
    super.initState();
    context.read<CheckoutCubit>().setProducts(widget.cartItems);
    context.read<CheckoutCubit>().getAddressFromLocalStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gap(16.h),
        CheckoutSteps(
          currentIndex: widget.currentIndex,
          steps: widget.steps,
          pageController: widget.pageController,
        ),
        Gap(24.h),
        CheckoutPageView(
          pageController: widget.pageController,
          onPageChanged: widget.onPageChanged,
          addressArgs: widget.addressArgs,
        ),
      ],
    );
  }
}
