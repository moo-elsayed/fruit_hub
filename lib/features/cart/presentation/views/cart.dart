import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/cart_item_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_items_list_view.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/products_count.dart';
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
  Widget build(BuildContext context) => NestedScrollView(
    headerSliverBuilder: (context, innerBoxIsScrolled) => [
      SliverAppBar(
        floating: true,
        snap: true,
        pinned: false,
        automaticallyImplyLeading: false,
        backgroundColor: context.colors.background,
        surfaceTintColor: context.colors.background,
        flexibleSpace: FlexibleSpaceBar(
          background: Padding(
            padding: EdgeInsetsGeometry.only(top: 10.h, bottom: 8.h),
            child: CustomAppBar(title: AppStrings.cartAppBar),
          ),
        ),
      ),
      SliverAppBar(
        pinned: true,
        floating: false,
        snap: false,
        automaticallyImplyLeading: false,
        backgroundColor: context.colors.background,
        surfaceTintColor: context.colors.background,
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
          bottom: 85.h,
          right: 16.w,
          left: 16.w,
          child: BlocConsumer<CartCubit, CartState>(
            listener: (context, state) {
              if (state is CartSuccess && state.items.isNotEmpty) {
                totalPrice = state.totalPrice.formattedPrice;
              }
            },
            builder: (context, state) {
              if (state is CartLoading && !state.itemRemoved) {
                return Skeletonizer(
                  enabled: true,
                  child: CustomMaterialButton(
                    onPressed: () {},
                    maxWidth: true,
                    text: '${AppStrings.checkout} 120 ${AppStrings.pounds}',
                    textStyle: AppTextStyles.font16Bold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                );
              }
              if ((state is CartSuccess && state.items.isNotEmpty) ||
                  (state is CartLoading && state.itemRemoved)) {
                return CustomMaterialButton(
                  onPressed: () => context.pushNamed(
                    Routes.checkoutView,
                    arguments: cartItemsList,
                  ),
                  maxWidth: true,
                  text:
                      '${AppStrings.checkout} $totalPrice ${AppStrings.pounds}',
                  textStyle: AppTextStyles.font16Bold.copyWith(
                    color: Colors.white,
                  ),
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
