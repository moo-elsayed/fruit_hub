import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/fruits_grid_view.dart';
import 'package:fruit_hub/features/home/presentation/views/best_seller_view.dart';
import 'package:fruit_hub/features/home/presentation/widgets/custom_home_app_bar.dart';
import 'package:fruit_hub/features/home/presentation/widgets/custom_slider_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../widgets/custom_section_header.dart';
import '../widgets/search_text_field.dart';

class Home extends StatelessWidget {
  const Home({super.key, required this.scrollControllers});

  final List<ScrollController> scrollControllers;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: CustomScrollView(
        controller: scrollControllers[0],
        slivers: [
          const SliverToBoxAdapter(child: CustomHomeAppBar()),
          SliverPadding(
            padding: EdgeInsets.only(right: 16.w, left: 16.w, bottom: 12.h),
            sliver: const SliverToBoxAdapter(child: SearchTextFiled()),
          ),
          const SliverToBoxAdapter(child: CustomSliderView()),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              child: CustomSectionHeader(
                sectionName: "best_seller".tr(),
                onTap: () =>
                    PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                      context,
                      settings: const RouteSettings(
                        name: Routes.bestSellerView,
                      ),
                      screen: BestSellerView(
                        scrollController: scrollControllers[1],
                      ),
                      withNavBar: true,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    ),
              ),
            ),
          ),
          const FruitsGridView(showFewFruit: true),
        ],
      ),
    );
  }
}
