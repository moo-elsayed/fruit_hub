import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signout_cubit/sign_out_cubit.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/cart/presentation/views/cart.dart';
import 'package:fruit_hub/features/favorites/presentation/views/favorites.dart';
import 'package:fruit_hub/features/home/presentation/managers/home_cubit/home_cubit.dart';
import 'package:fruit_hub/features/home/presentation/views/home.dart';
import 'package:fruit_hub/features/main/presentation/items/nav_bar_item.dart';
import 'package:fruit_hub/features/main/presentation/managers/main_tab_notifier.dart';
import 'package:fruit_hub/features/main/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:fruit_hub/features/profile/presentation/views/profile.dart';
import 'package:toastification/toastification.dart';

class MainView extends StatefulWidget {
  const MainView({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  void initState() {
    super.initState();
    MainTabNotifier.currentTab.value = widget.initialIndex;
  }

  final List<Widget> _screens = [
    BlocProvider(
      create: (context) => getIt.get<HomeCubit>(),
      child: const Home(),
    ),
    const Favorites(),
    const Cart(),
    BlocProvider(
      create: (context) => getIt.get<SignOutCubit>(),
      child: const Profile(),
    ),
  ];

  List<NavBarItem> get _navItems => [
    NavBarItem(
      icon: AppAssets.iconsHomeOutline,
      activeIcon: AppAssets.iconsHomeFilled,
      label: AppStrings.home,
    ),
    NavBarItem(
      icon: AppAssets.iconsHeart,
      activeIcon: AppAssets.iconsHeart,
      label: AppStrings.favorites,
    ),
    NavBarItem(
      icon: AppAssets.iconsShoppingCartOutline,
      activeIcon: AppAssets.iconsShoppingCartFilled,
      label: AppStrings.shoppingCart,
    ),
    NavBarItem(
      icon: AppAssets.iconsProfileOutline,
      activeIcon: AppAssets.iconsProfileFilled,
      label: AppStrings.myAccount,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Listen to locale changes so nav items and screens rebuild dynamically
    final _ = EasyLocalization.of(context)?.locale;

    return ValueListenableBuilder<int>(
      valueListenable: MainTabNotifier.currentTab,
      builder: (context, currentIndex, _) => PopScope(
        canPop: currentIndex == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && currentIndex != 0) {
            MainTabNotifier.switchToTab(0);
          }
        },
        child: BlocListener<CartCubit, CartState>(
          listenWhen: (previous, current) =>
              current is CartSuccess || current is CartFailure,
          listener: (context, state) {
            if (ModalRoute.of(context)?.isCurrent != true) return;
            if (state is CartSuccess &&
                (state.itemRemoved || state.newItemAdded)) {
              AppToast.show(
                context: context,
                title: state.newItemAdded
                    ? AppStrings.itemAddedToCart
                    : AppStrings.itemRemovedFromCart,
                type: ToastificationType.success,
              );
            } else if (state is CartSuccess && state.itemAlreadyExists) {
              AppToast.show(
                context: context,
                title: AppStrings.itemAlreadyInCart,
                type: ToastificationType.warning,
              );
            } else if (state is CartFailure) {
              AppToast.show(
                context: context,
                title: state.errorMessage,
                type: ToastificationType.error,
              );
            }
          },
          child: Scaffold(
            extendBody: true,
            body: SafeArea(
              bottom: false,
              child: IndexedStack(index: currentIndex, children: _screens),
            ),
            bottomNavigationBar: CustomBottomNavigationBar(
              currentIndex: currentIndex,
              items: _navItems,
              onTabSelected: (index) => MainTabNotifier.switchToTab(index),
            ),
          ),
        ),
      ),
    );
  }
}
