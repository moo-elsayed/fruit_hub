import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/widgets/custom_empty_state_widget.dart';
import 'package:fruit_hub/core/widgets/main_screen_header.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_checkout_bottom_bar.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_header_badge.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_items_list_view.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/free_shipping_progress_bar.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().getProductsInCart();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final items = state is CartSuccess
            ? state.items
            : context.read<CartCubit>().productsInCart;
        final num totalPrice = state is CartSuccess
            ? state.totalPrice.formattedPrice
            : 0;
        final shippingConfig = state is CartSuccess
            ? state.shippingConfig
            : context.read<CartCubit>().shippingConfig;

        return Column(
          children: [
            Gap(12.h),
            MainScreenHeader(
              title: AppStrings.cartAppBar,
              action: items.isNotEmpty
                  ? CartHeaderBadge(count: items.length)
                  : null,
            ),
            Gap(12.h),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state is CartLoading && !state.itemRemoved) {
                    return const Skeletonizer(
                      enabled: true,
                      child: CartItemsListView(itemCount: 3),
                    );
                  }

                  if (items.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 85.h),
                      child: CustomEmptyStateWidget(
                        customIcon: Container(
                          width: 100.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                            color: context.colors.primary.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              size: 48.r,
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                        title: AppStrings.shoppingCart,
                        text: AppStrings.emptyCartSubtitle,
                      ),
                    );
                  }

                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Column(
                        children: [
                          if (shippingConfig?.freeShippingThreshold != null &&
                              shippingConfig!.freeShippingThreshold! > 0) ...[
                            FreeShippingProgressBar(
                              shippingConfig: shippingConfig,
                              totalPrice: totalPrice,
                            ),
                            Gap(12.h),
                          ],
                          Expanded(child: CartItemsListView(cartItems: items)),
                        ],
                      ),
                      Positioned(
                        bottom: 85.h,
                        left: 0,
                        right: 0,
                        child: CartCheckoutBottomBar(
                          cartItems: items,
                          totalPrice: totalPrice,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  );
}
