import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/fruits_grid_view.dart';
import 'package:fruit_hub/features/profile/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:fruit_hub/features/search/presentation/widgets/search_placeholder_widget.dart';
import 'package:toastification/toastification.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
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
      CustomAppBar(title: AppStrings.favorites),
      Expanded(
        child: Padding(
          padding: EdgeInsetsGeometry.only(top: 8.h),
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
              if (state is GetFavoritesLoading &&
                  cubit.favoriteFruits.isEmpty) {
                return const FruitsGridView(itemCount: 4);
              }
              final favorites = cubit.favoriteFruits;
              if (favorites.isEmpty) {
                return SearchPlaceholderWidget(text: AppStrings.noFavorites);
              }
              return FruitsGridView(fruits: favorites, fromFavorite: true);
            },
          ),
        ),
      ),
    ],
  );
}
