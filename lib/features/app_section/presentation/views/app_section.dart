import 'package:flutter/material.dart';
import 'package:fruit_hub/features/products/presentation/views/products.dart';
import '../../../cart/presentation/views/cart.dart';
import '../../../home/presentation/views/home.dart';
import '../../../profile/presentation/views/profile.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class AppSection extends StatefulWidget {
  const AppSection({super.key});

  @override
  State<AppSection> createState() => _AppSectionState();
}

class _AppSectionState extends State<AppSection> {
  final List<Widget> _pages = [
    const Home(),
    const Products(),
    const Cart(),
    const Profile(),
  ];

  int _index = 0;

  _onItemTapped(index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
