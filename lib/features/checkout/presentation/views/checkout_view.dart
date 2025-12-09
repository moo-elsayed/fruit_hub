import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/add_order_use_case.dart';
import 'package:fruit_hub/features/checkout/domain/use_cases/fetch_shipping_config_use_case.dart';
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
  int currentIndex = 0;

  List<String> get steps => ["address".tr(), "payment".tr(), "review".tr()];

  @override
  void initState() {
    super.initState();
    addressArgs = AddressArgs();
    _pageController = PageController();
  }

  @override
  void dispose() {
    addressArgs.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CheckoutCubit(
              getIt.get<AppPreferencesManager>(),
              getIt.get<FetchShippingConfigUseCase>(),
              getIt.get<AddOrderUseCase>(),
            )
            ..setProducts(widget.cartItems)
            ..getAddressFromLocalStorage()
            ..fetchShippingConfig(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: CustomAppBar(
              title: steps[currentIndex],
              showArrowBack: true,
              onTap: () => context.pop(),
            ),
            body: Column(
              children: [
                Gap(16.h),
                CheckoutSteps(
                  currentIndex: currentIndex,
                  steps: steps,
                  pageController: _pageController,
                ),
                Gap(24.h),
                CheckoutPageView(
                  pageController: _pageController,
                  onPageChanged: (value) =>
                      setState(() => currentIndex = value),
                  addressArgs: addressArgs,
                ),
              ],
            ),
            bottomNavigationBar: MediaQuery.viewInsetsOf(context).bottom != 0
                ? null
                : Padding(
                    padding: .symmetric(horizontal: 16.w, vertical: 16.h),
                    child: CheckoutButtonBlocConsumer(
                      pageController: _pageController,
                      currentIndex: currentIndex,
                      addressArgs: addressArgs,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
