import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/products_count.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_items_list_view.dart';
import 'package:skeletonizer/skeletonizer.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().getCartItems();
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
            child: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                if (state is CartLoading) {
                  return Skeletonizer(
                    enabled: true,
                    child: ProductsCount(count: cartItemsList.length),
                  );
                }
                if (state is CartSuccess) {
                  cartItemsList = state.items;
                  int count = state.totalItemCount;
                  return ProductsCount(count: count);
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
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartLoading) {
                return const Skeletonizer(
                  enabled: true,
                  child: CartItemsListView(itemCount: 6),
                );
              }
              if (state is CartSuccess) {
                cartItemsList = state.items;
                return CartItemsListView(cartItems: cartItemsList);
              }
              return Container();
            },
          ),
          Positioned(
            bottom: 16.h,
            right: 16.w,
            left: 16.w,
            child: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                if (state is CartLoading) {
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
                if (state is CartSuccess && state.items.isNotEmpty) {
                  num totalPrice = getPrice(state.totalPrice);
                  return CustomMaterialButton(
                    onPressed: () {},
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
