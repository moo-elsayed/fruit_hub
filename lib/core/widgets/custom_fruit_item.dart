import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_action_button.dart';
import 'package:fruit_hub/core/widgets/custom_favourite_icon.dart';
import 'package:fruit_hub/core/widgets/custom_network_image.dart';
import 'package:fruit_hub/core/widgets/price_per_kilo.dart';
import 'package:fruit_hub/core/widgets/product_badge.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/profile/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:gap/gap.dart';

class CustomFruitItem extends StatelessWidget {
  const CustomFruitItem({super.key, required this.fruitEntity});

  final FruitEntity fruitEntity;

  @override
  Widget build(BuildContext context) {
    final myFavoriteService = context.read<FavoriteCubit>();
    final myCartService = context.read<CartCubit>();

    return GestureDetector(
      onTap: () =>
          context.pushNamed(Routes.productDetailsView, arguments: fruitEntity),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: context.colors.surface,
              border: Border.all(color: context.colors.border, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: fruitEntity.imagePath.isNotEmpty
                            ? Hero(
                                tag:
                                    'fruit_hero_${fruitEntity.code}_${fruitEntity.imagePath}',
                                child: CustomNetworkImage(
                                  image: fruitEntity.imagePath,
                                ),
                              )
                            : CustomNetworkImage(image: fruitEntity.imagePath),
                      ),
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    fruitEntity.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.font14Bold.copyWith(
                      color: context.colors.mainText,
                    ),
                  ),
                  Gap(2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: PricePerKilo(price: fruitEntity.price)),
                      CustomActionButton(
                        onTap: () {
                          myCartService.addItemToCart(fruitEntity.code);
                        },
                        child: SvgPicture.asset(AppAssets.iconsPlus),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            top: 8.h,
            start: 8.w,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (fruitEntity.isOrganic)
                  ProductBadge(
                    icon: Icons.eco_rounded,
                    color: context.colors.primary,
                    tooltip: AppStrings.organic,
                  ),
                if (fruitEntity.isOrganic && fruitEntity.isFeatured) Gap(4.w),
                if (fruitEntity.isFeatured)
                  ProductBadge(
                    icon: Icons.star_rounded,
                    color: Colors.amber,
                    tooltip: AppStrings.featured,
                  ),
              ],
            ),
          ),
          BlocBuilder<FavoriteCubit, FavoriteState>(
            buildWhen: (previous, current) => current is ToggleFavoriteSuccess,
            builder: (context, state) => PositionedDirectional(
              end: 6.w,
              top: 6.h,
              child: CustomFavouriteIcon(
                onChanged: () => myFavoriteService.toggleFavorite(fruitEntity),
                isFavourite: myFavoriteService.isFavorite(fruitEntity.code),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
