import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/dependency_injection.dart';
import 'package:fruit_hub/core/services/local_storage/local_storage_service.dart';
import 'package:fruit_hub/core/theming/app_colors.dart';
import 'package:fruit_hub/features/app_section/domain/entities/bottom_navigation_bar_entity.dart';
import 'package:fruit_hub/features/app_section/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:fruit_hub/features/home/domain/use_cases/get_best_seller_products_use_case.dart';
import 'package:fruit_hub/features/home/presentation/managers/home_cubit/home_cubit.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/views/products.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../cart/presentation/views/cart.dart';
import '../../../home/presentation/views/home.dart';
import '../../../products/domain/use_cases/get_all_products_use_case.dart';
import '../../../profile/presentation/views/profile.dart';

class AppSection extends StatefulWidget {
  const AppSection({super.key});

  @override
  State<AppSection> createState() => _AppSectionState();
}

class _AppSectionState extends State<AppSection> {
  late PersistentTabController _controller;
  final items = bottomNavigationBarItems;
  late final List<Widget> _pages = [
    BlocProvider(
      create: (context) => HomeCubit(
        getIt.get<GetBestSellerProductsUseCase>(),
        getIt.get<LocalStorageService>(),
      ),
      child: const Home(),
    ),
    BlocProvider(
      create: (context) => ProductsCubit(getIt.get<GetAllProductsUseCase>()),
      child: const Products(),
    ),
    const Cart(),
    const Profile(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(34.h),
        child: ColoredBox(
          color: AppColors.white,
          child: SizedBox(height: 34.h),
        ),
      ),
      body: PersistentTabView.custom(
        resizeToAvoidBottomInset: true,
        context,
        controller: _controller,
        screens: _buildScreens(),
        itemCount: _pages.length,
        customWidget: _buildCustomNavBar(),
        confineToSafeArea: true,
        handleAndroidBackButtonPress: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardAppears: true,
        hideOnScrollSettings: const HideOnScrollSettings(
          hideNavBarOnScroll: true,
        ),
        animationSettings: const NavBarAnimationSettings(
          onNavBarHideAnimation: OnHideAnimationSettings(
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }

  List<CustomNavBarScreen> _buildScreens() => List.generate(
    _pages.length,
    (index) => CustomNavBarScreen(
      screen: ColoredBox(color: AppColors.white, child: _pages[index]),
    ),
  );

  Widget _buildCustomNavBar() => Material(
    color: Colors.transparent,
    child: CustomBottomNavigationBar(
      onItemTapped: (index) {
        _controller.jumpToTab(index);
      },
    ),
  );
}
