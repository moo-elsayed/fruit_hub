import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_empty_state_widget.dart';
import 'package:fruit_hub/core/widgets/fruits_grid_view.dart';
import 'package:fruit_hub/core/widgets/main_screen_header.dart';
import 'package:fruit_hub/features/favorites/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:toastification/toastification.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<FavoriteCubit>();
    if (cubit.favoriteFruits.isEmpty && cubit.favoriteIds.isEmpty) {
      cubit.getFavorites();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: EdgeInsetsGeometry.only(
          left: 16.w,
          right: 16.w,
          top: 12.h,
          bottom: 12.h,
        ),
        child: MainScreenHeader(title: AppStrings.favorites),
      ),
      Expanded(
        child: BlocConsumer<FavoriteCubit, FavoriteState>(
          listener: (context, state) {
            if (state is GetFavoritesFailure ||
                state is ToggleFavoriteFailure) {
              final message = state is GetFavoritesFailure
                  ? state.errorMessage
                  : (state as ToggleFavoriteFailure).errorMessage;
              AppToast.show(
                context: context,
                title: message,
                type: ToastificationType.error,
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<FavoriteCubit>();
            if (state is GetFavoritesLoading && cubit.favoriteFruits.isEmpty) {
              return const FruitsGridView(itemCount: 4, needTopPadding: false);
            }
            final favorites = cubit.favoriteFruits;
            if (favorites.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(bottom: 85.h),
                child: CustomEmptyStateWidget(
                  customIcon: Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 48.r,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  title: AppStrings.favorites,
                  text: AppStrings.noFavorites,
                ),
              );
            }
            return FruitsGridView(
              fruits: favorites,
              fromFavorite: true,
              needTopPadding: false,
            );
          },
        ),
      ),
    ],
  );
}
