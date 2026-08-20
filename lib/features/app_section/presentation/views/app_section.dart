import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/core/theming/app_colors.dart';
import 'package:fruit_hub/core/widgets/app_dialogs.dart';
import 'package:fruit_hub/features/app_section/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/home/domain/use_cases/get_best_seller_products_use_case.dart';
import 'package:fruit_hub/features/home/presentation/managers/home_cubit/home_cubit.dart';
import 'package:fruit_hub/features/products/domain/use_cases/get_product_details_use_case.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/views/products.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../core/helpers/extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/app_toasts.dart';
import '../../../../main.dart';
import '../../../auth/domain/use_cases/sign_out_use_case.dart';
import '../../../auth/presentation/managers/signout_cubit/sign_out_cubit.dart';
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
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  String? _lastOpenedId;
  late PersistentTabController _controller;
  final List<Widget> _pages = [
    BlocProvider(
      create: (context) => HomeCubit(
        getIt.get<GetBestSellerProductsUseCase>(),
        getIt.get<AppPreferencesManager>(),
      ),
      child: const Home(),
    ),
    BlocProvider(
      create: (context) => ProductsCubit(
        getAllProductsUseCase: getIt.get<GetAllProductsUseCase>(),
        getProductDetailsUseCase: getIt.get<GetProductDetailsUseCase>(),
      ),
      child: const Products(),
    ),
    const Cart(),
    BlocProvider(
      create: (context) => SignOutCubit(getIt.get<SignOutUseCase>()),
      child: const Profile(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _controller.addListener(() {
      setState(() {});
    });
    _initDeepLinks();
  }

  void _initDeepLinks() {
    // 1. لو الأبلكيشن كان مقفول (Cold Start)، هنلاقي اللينك مستنينا في المتغير العالمي
    if (globalInitialLinkProductId != null) {
      _openProductSafely(globalInitialLinkProductId!);
      globalInitialLinkProductId = null; // نفضيه عشان ميفتحش تاني
    }

    // 2. لو الأبلكيشن شغال في الخلفية (Background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'fruithub' && uri.host == 'product') {
        _openProductSafely(uri.pathSegments.first);
      }
    });
  }

  void _openProductSafely(String productId) {
    if (_lastOpenedId == productId) return;
    _lastOpenedId = productId;


    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamed(Routes.productDetailsView, arguments: productId);
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _lastOpenedId = null;
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<CartCubit, CartState>(
    listenWhen: (previous, current) =>
        current is CartSuccess || current is CartLoading,
    listener: (context, state) {
      if (state is CartLoading && state.itemRemoved) {
        AppDialogs.showLoadingDialog(context);
      }
      if (state is CartLoading && state.newItemAdded) {
        AppDialogs.showLoadingDialog(context);
      }
      if (state is CartSuccess && (state.itemRemoved || state.newItemAdded)) {
        context.pop();
        AppToast.showToast(
          context: context,
          title: state.newItemAdded
              ? 'item_added_to_cart'.tr()
              : 'item_removed_from_cart'.tr(),
          type: .success,
        );
      }
    },
    child: Scaffold(
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
    ),
  );

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
