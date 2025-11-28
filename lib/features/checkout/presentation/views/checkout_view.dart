import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/helpers/dependency_injection.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/services/local_storage/local_storage_service.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/features/checkout/presentation/args/address_args.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/checkout_view_body.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_material_button.dart';

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

  List<String> get buttonTexts => [
    "next".tr(),
    "confirm_and_continue".tr(),
    "confirm_order".tr(),
  ];

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
      create: (context) => CheckoutCubit(getIt.get<LocalStorageService>()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: CustomAppBar(
              title: steps[currentIndex],
              showArrowBack: true,
              onTap: () => context.pop(),
            ),
            body: CheckoutViewBody(
              addressArgs: addressArgs,
              pageController: _pageController,
              currentIndex: currentIndex,
              steps: steps,
              cartItems: widget.cartItems,
              onPageChanged: (value) => setState(() => currentIndex = value),
            ),
            bottomNavigationBar: MediaQuery.viewInsetsOf(context).bottom != 0
                ? null
                : Padding(
                    padding: .symmetric(horizontal: 16.w, vertical: 16.h),
                    child: CustomMaterialButton(
                      onPressed: () {
                        // if (currentIndex == 0 && addressArgs.isValid) {
                        //   context
                        //       .read<CheckoutCubit>()
                        //       .setAddress(addressArgs.toEntity());
                        // }
                        // if (currentIndex == 1) {
                        //   // context.read<CheckoutCubit>().setPaymentOption(
                        //   //   paymentOptions,
                        //   // );
                        // }
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      text: buttonTexts[currentIndex],
                      textStyle: AppTextStyles.font16WhiteBold,
                      maxWidth: true,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
