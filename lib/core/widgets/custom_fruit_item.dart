import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_colors.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_favourite_icon.dart';
import 'package:fruit_hub/core/widgets/price_per_kilo.dart';
import 'package:fruit_hub/features/products/presentation/views/product_details_view.dart';
import 'package:fruit_hub/generated/assets.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import '../../features/profile/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'custom_action_button.dart';
import 'custom_network_image.dart';

class CustomFruitItem extends StatelessWidget {
  const CustomFruitItem({super.key, required this.fruitEntity});

  final FruitEntity fruitEntity;

  @override
  Widget build(BuildContext context) {
    var myFavoriteService = context.read<FavoriteCubit>();
    var myCartService = context.read<CartCubit>();
    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
          context,
          settings: const RouteSettings(name: Routes.productDetailsView),
          screen: ProductDetailsView(fruitEntity: fruitEntity),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Stack(
        children: [
          Container(
            padding: .symmetric(
              vertical: 20.h,
              horizontal: 10.w,
            ),
            decoration: BoxDecoration(
              borderRadius: .circular(4.r),
              color: AppColors.colorF3F5F7,
            ),
            child: Column(
              mainAxisAlignment: .spaceBetween,
              spacing: 8.h,
              children: [
                Flexible(
                  child: CustomNetworkImage(image: fruitEntity.imagePath),
                ),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  crossAxisAlignment: .end,
                  children: [
                    Column(
                      crossAxisAlignment: .start,
                      spacing: 4.h,
                      children: [
                        Text(
                          fruitEntity.name,
                          style: AppTextStyles.font13color0C0D0DSemiBold,
                        ),
                        PricePerKilo(price: fruitEntity.price),
                      ],
                    ),
                    CustomActionButton(
                      onTap: () {
                        myCartService.addItemToCart(fruitEntity.code);
                      },
                      child: SvgPicture.asset(Assets.iconsPlus),
                    ),
                  ],
                ),
              ],
            ),
          ),
          BlocBuilder<FavoriteCubit, FavoriteState>(
            buildWhen: (previous, current) => current is ToggleFavoriteSuccess,
            builder: (context, state) {
              return PositionedDirectional(
                start: 4.w,
                top: 4.h,
                child: CustomFavouriteIcon(
                  onChanged: () =>
                      myFavoriteService.toggleFavorite(fruitEntity.code),
                  isFavourite: myFavoriteService.isFavorite(fruitEntity.code),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
