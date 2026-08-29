import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/widgets/custom_arrow_back.dart';
import 'package:fruit_hub/core/widgets/custom_favourite_icon.dart';
import 'package:fruit_hub/core/widgets/custom_network_image.dart';
import 'package:fruit_hub/features/favorites/presentation/managers/favorite_cubit/favorite_cubit.dart';

class ProductDetailsHeader extends StatelessWidget {
  const ProductDetailsHeader({super.key, required this.fruit});

  final FruitEntity fruit;

  @override
  Widget build(BuildContext context) {
    final favoriteCubit = context.read<FavoriteCubit>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: context.colors.mainText.withValues(alpha: 0.04),
            blurRadius: 16.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomArrowBack(onTap: () => context.pop(), size: 40.r),
                  BlocBuilder<FavoriteCubit, FavoriteState>(
                    buildWhen: (previous, current) =>
                        current is ToggleFavoriteSuccess,
                    builder: (context, state) => Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.surface,
                        border: Border.all(
                          color: context.colors.border,
                          width: 1.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.mainText.withValues(
                              alpha: 0.04,
                            ),
                            blurRadius: 8.r,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: CustomFavouriteIcon(
                        onChanged: () => favoriteCubit.toggleFavorite(fruit),
                        isFavourite: favoriteCubit.isFavorite(fruit.code),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 4.h,
                bottom: 16.h,
                right: 24.w,
                left: 24.w,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: CustomNetworkImage(
                  image: fruit.imagePath,
                  height: 190.h,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
