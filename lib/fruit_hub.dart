import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/routing/app_router.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_colors.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/add_item_to_cart_use_case.dart';
import 'package:fruit_hub/features/cart/domain/use_cases/remove_item_from_cart_use_case.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/add_item_to_favorites_use_case.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/get_favorite_ids_use_case.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/get_favorites_use_case.dart';
import 'package:fruit_hub/features/profile/domain/use_cases/remove_item_from_favorites_use_case.dart';
import 'package:fruit_hub/features/profile/presentation/managers/favorite_cubit/favorite_cubit.dart';
import 'features/cart/domain/use_cases/clear_cart_use_case.dart';
import 'features/cart/domain/use_cases/get_cart_items_use_case.dart';
import 'features/cart/domain/use_cases/get_products_in_cart_use_case.dart';
import 'features/cart/domain/use_cases/update_item_quantity_use_case.dart';

class FruitHub extends StatelessWidget {
  const FruitHub({super.key, required this.appRouter});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => CartCubit(
              getIt.get<AddItemToCartUseCase>(),
              getIt.get<RemoveItemFromCartUseCase>(),
              getIt.get<GetProductsInCartUseCase>(),
              getIt.get<UpdateItemQuantityUseCase>(),
              getIt.get<GetCartItemsUseCase>(),
              getIt.get<ClearCartUseCase>(),
            )..getCartItems(),
          ),
          BlocProvider(
            create: (context) => FavoriteCubit(
              getIt.get<AddItemToFavoritesUseCase>(),
              getIt.get<RemoveItemFromFavoritesUseCase>(),
              getIt.get<GetFavoriteIdsUseCase>(),
              getIt.get<GetFavoritesUseCase>(),
            )..getFavoriteIds(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: appRouter.generateRoute,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.white,
              surfaceTintColor: AppColors.white,
            ),
          ),
          initialRoute: Routes.splashView,
        ),
      ),
    );
  }
}
