import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/products_count.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_items_list_view.dart';
import 'package:fruit_hub/features/checkout/presentation/views/checkout_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../managers/cart_cubit/cart_cubit.dart';

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
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          floating: true,
          snap: true,
          pinned: false,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.white,
          surfaceTintColor: AppColors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: EdgeInsetsGeometry.only(top: 10.h, bottom: 8.h),
              child: CustomAppBar(title: "cart_app_bar".tr()),
            ),
          ),
        ),
        SliverAppBar(
          pinned: true,
          floating: false,
          snap: false,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.white,
          surfaceTintColor: AppColors.white,
          toolbarHeight: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(44.h),
            child: BlocConsumer<CartCubit, CartState>(
              listener: (context, state) {
                if (state is CartSuccess) {
                  cartItemsList = state.items;
                }
              },
              builder: (context, state) {
                if (state is CartLoading && !state.itemRemoved) {
                  return Skeletonizer(
                    enabled: true,
                    child: ProductsCount(count: cartItemsList.length),
                  );
                }
                if (state is CartSuccess ||
                    (state is CartLoading && state.itemRemoved)) {
                  return ProductsCount(count: cartItemsList.length);
                }
                return Container();
              },
            ),
          ),
        ),
      ],
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          BlocConsumer<CartCubit, CartState>(
            listener: (context, state) {
              if (state is CartSuccess) {
                cartItemsList = state.items;
              }
            },
            builder: (context, state) {
              if (state is CartLoading && !state.itemRemoved) {
                return const Skeletonizer(
                  enabled: true,
                  child: CartItemsListView(itemCount: 6),
                );
              }
              if (state is CartSuccess ||
                  (state is CartLoading && state.itemRemoved)) {
                return CartItemsListView(cartItems: cartItemsList);
              }
              return Container();
            },
          ),
          Positioned(
            bottom: 16.h,
            right: 16.w,
            left: 16.w,
            child: BlocConsumer<CartCubit, CartState>(
              listener: (context, state) {
                if (state is CartSuccess && state.items.isNotEmpty) {
                  totalPrice = getPrice(state.totalPrice);
                }
              },
              builder: (context, state) {
                if (state is CartLoading && !state.itemRemoved) {
                  return Skeletonizer(
                    enabled: true,
                    child: CustomMaterialButton(
                      onPressed: () {},
                      maxWidth: true,
                      text: "${"checkout".tr()} 120 ${"pounds".tr()}",
                      textStyle: AppTextStyles.font16WhiteBold,
                    ),
                  );
                }
                if ((state is CartSuccess && state.items.isNotEmpty) ||
                    (state is CartLoading && state.itemRemoved)) {
                  return CustomMaterialButton(
                    onPressed: () {
                      PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                        context,
                        settings: const RouteSettings(
                          name: Routes.checkoutView,
                        ),
                        screen: CheckoutView(cartItems: cartItemsList),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    maxWidth: true,
                    text: "${"checkout".tr()} $totalPrice ${"pounds".tr()}",
                    textStyle: AppTextStyles.font16WhiteBold,
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
