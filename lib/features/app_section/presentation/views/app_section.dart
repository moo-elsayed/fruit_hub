import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/features/app_section/domain/entities/bottom_navigation_bar_entity.dart';
import 'package:fruit_hub/features/app_section/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:fruit_hub/features/products/presentation/views/products.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../cart/presentation/views/cart.dart';
import '../../../home/presentation/views/home.dart';
import '../../../profile/presentation/views/profile.dart';

class AppSection extends StatefulWidget {
  const AppSection({super.key});

  @override
  State<AppSection> createState() => _AppSectionState();
}

class _AppSectionState extends State<AppSection> {
  late PersistentTabController _controller;
  final items = bottomNavigationBarItems;
  final List<Widget> _pages = const [Home(), Products(), Cart(), Profile()];

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView.custom(
      context,
      controller: _controller,
      screens: _buildScreens(),
      itemCount: _pages.length,
      customWidget: _buildCustomNavBar(),
      confineToSafeArea: true,
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      navBarHeight: 70.h,
    );
  }

  List<CustomNavBarScreen> _buildScreens() => List.generate(
    _pages.length,
    (index) => CustomNavBarScreen(screen: _pages[index]),
  );

  Widget _buildCustomNavBar() => Material(
    child: SafeArea(
      top: false,
      child: CustomBottomNavigationBar(
        onItemTapped: (index) {
          _controller.jumpToTab(index);
        },
      ),
    ),
  );
}
