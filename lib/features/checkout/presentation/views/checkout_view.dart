import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/features/checkout/presentation/args/address_args.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/checkout_button_bloc_consumer.dart';
import 'package:gap/gap.dart';

import '../widgets/checkout_page_view.dart';
import '../widgets/checkout_steps.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key, required this.cartItems});

  final List<CartItemEntity> cartItems;

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  late AddressArgs addressArgs;
  late PageController _pageController;
  late CheckoutCubit _checkoutCubit;
  int currentIndex = 0;

  List<String> get steps => [
    AppStrings.address,
    AppStrings.payment,
    AppStrings.review,
  ];

  @override
  void initState() {
    super.initState();
    addressArgs = AddressArgs();
    _pageController = PageController();
    _checkoutCubit = getIt.get<CheckoutCubit>()
      ..setProducts(widget.cartItems)
      ..getAddressFromLocalStorage()
      ..fetchShippingConfig();
  }

  @override
  void dispose() {
    addressArgs.dispose();
    _pageController.dispose();
    _checkoutCubit.close();
    super.dispose();
  }

  void _handleBackNavigation() {
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _checkoutCubit,
    child: PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex > 0) {
          _handleBackNavigation();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: steps[currentIndex],
          showArrowBack: true,
          onTap: _handleBackNavigation,
        ),
        body: Column(
          children: [
            Gap(16.h),
            CheckoutSteps(
              currentIndex: currentIndex,
              steps: steps,
              onStepTapped: (index) => _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
            ),
            Gap(24.h),
            CheckoutPageView(
              pageController: _pageController,
              onPageChanged: (value) => setState(() => currentIndex = value),
              addressArgs: addressArgs,
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: CheckoutButtonBlocConsumer(
            onNext: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
            currentIndex: currentIndex,
            addressArgs: addressArgs,
          ),
        ),
      ),
    ),
  );
}
