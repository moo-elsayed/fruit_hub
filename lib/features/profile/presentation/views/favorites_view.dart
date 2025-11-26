import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/fruits_grid_view.dart';
import 'package:fruit_hub/features/profile/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  List<FruitEntity> favorites = [];

  @override
  void initState() {
    super.initState();
    context.read<FavoriteCubit>().getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "favorites".tr(),
        showArrowBack: true,
        onTap: () => context.pop(),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.only(top: 8.h),
        child: BlocConsumer<FavoriteCubit, FavoriteState>(
          listener: (context, state) {
            if (state is GetFavoritesSuccess) {
              favorites = state.favorites;
            }
            if (state is ToggleFavoriteSuccess) {
              favorites.removeWhere(
                (element) => !state.favoriteIds.contains(element.code),
              );
            }
            if (state is GetFavoritesFailure) {
              AppToast.showToast(
                context: context,
                title: state.errorMessage,
                type: ToastificationType.error,
              );
            }
          },
          builder: (context, state) {
            if (state is GetFavoritesLoading) {
              return const Skeletonizer(
                enabled: true,
                child: FruitsGridView(itemCount: 4),
              );
            }
            return FruitsGridView(fruits: favorites, fromFavorite: true);
          },
        ),
      ),
    );
  }
}
