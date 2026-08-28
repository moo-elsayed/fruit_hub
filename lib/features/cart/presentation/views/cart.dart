import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_empty_state_widget.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/main_screen_header.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_items_list_view.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/products_count.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  var cartItemsList = <CartItemEntity>[];
  num totalPrice = 0;

  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().getProductsInCart();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Column(
      children: [
        Gap(12.h),
        MainScreenHeader(title: AppStrings.cartAppBar),
        Gap(12.h),
        BlocConsumer<CartCubit, CartState>(
          listener: (context, state) {
            if (state is CartSuccess) {
              cartItemsList = state.items;
              totalPrice = state.totalPrice.formattedPrice;
            }
          },
          builder: (context, state) {
            if (state is CartLoading && !state.itemRemoved) {
              return Skeletonizer(
                enabled: true,
                child: ProductsCount(count: cartItemsList.length),
              );
            }
            if (cartItemsList.isNotEmpty) {
              return ProductsCount(count: cartItemsList.length);
            }
            return const SizedBox.shrink();
          },
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  if (state is CartLoading && !state.itemRemoved) {
                    return const Skeletonizer(
                      enabled: true,
                      child: CartItemsListView(itemCount: 6),
                    );
                  }
                  if (cartItemsList.isEmpty) {
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
                  return CartItemsListView(cartItems: cartItemsList);
                },
              ),
              BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  if (cartItemsList.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    bottom: 85.h,
                    right: 0,
                    left: 0,
                    child: CustomMaterialButton(
                      onPressed: () => context.pushNamed(
                        Routes.checkoutView,
                        arguments: cartItemsList,
                      ),
                      maxWidth: true,
                      text:
                          '${AppStrings.checkout} $totalPrice ${AppStrings.pounds}',
                      textStyle: AppTextStyles.font16Bold.copyWith(
                        color: AppPalette.white,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
