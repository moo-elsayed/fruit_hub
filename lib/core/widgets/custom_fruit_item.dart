import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/theming/app_colors.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_favourite_icon.dart';
import 'package:fruit_hub/generated/assets.dart';
import '../../features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import '../../features/profile/presentation/managers/favorite_cubit/favorite_cubit.dart';
import '../helpers/functions.dart';
import 'custom_action_button.dart';
import 'custom_network_image.dart';

class CustomFruitItem extends StatelessWidget {
  const CustomFruitItem({super.key, required this.fruitEntity});

  final FruitEntity fruitEntity;

  @override
  Widget build(BuildContext context) {
    var myFavoriteService = context.read<FavoriteCubit>();
    var myCartService = context.read<CartCubit>();
    return Stack(
      children: [
        Container(
          padding: EdgeInsetsGeometry.symmetric(
            vertical: 20.h,
            horizontal: 10.w,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadiusGeometry.circular(4.r),
            color: AppColors.colorF3F5F7,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 8.h,
            children: [
              Flexible(child: CustomNetworkImage(image: fruitEntity.imagePath)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4.h,
                    children: [
                      Text(
                        fruitEntity.name,
                        style: AppTextStyles.font13color0C0D0DSemiBold,
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "${getPrice(fruitEntity.price)} ${"pounds".tr()}",
                              style: AppTextStyles.font13colorF4A91FSemiBold,
                            ),
                            TextSpan(
                              text: " / ${"kilo".tr()}",
                              style: AppTextStyles.font13colorF8C76DSemiBold,
                            ),
                          ],
                        ),
                      ),
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
    );
  }
}
