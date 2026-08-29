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
import 'package:fruit_hub/features/favorites/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:gap/gap.dart';

class CustomFruitItem extends StatelessWidget {
  const CustomFruitItem({super.key, required this.fruitEntity});

  final FruitEntity fruitEntity;

  @override
  Widget build(BuildContext context) {
    final myFavoriteCubit = context.read<FavoriteCubit>();

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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: CustomNetworkImage(
                        image: fruitEntity.imagePath,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.fill,
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
                        onTap: () => context.read<CartCubit>().addItemToCart(
                          fruitEntity,
                        ),
                        child: SvgPicture.asset(
                          AppAssets.iconsPlus,
                          width: 14.w,
                          height: 14.h,
                        ),
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
                onChanged: () => myFavoriteCubit.toggleFavorite(fruitEntity),
                isFavourite: myFavoriteCubit.isFavorite(fruitEntity.code),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
