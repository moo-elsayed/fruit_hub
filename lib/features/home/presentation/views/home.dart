import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/fruits_grid_view.dart';
import 'package:fruit_hub/features/home/presentation/managers/home_cubit/home_cubit.dart';
import 'package:fruit_hub/features/home/presentation/views/best_seller_view.dart';
import 'package:fruit_hub/features/home/presentation/widgets/custom_home_app_bar.dart';
import 'package:fruit_hub/features/home/presentation/widgets/custom_slider_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../widgets/custom_section_header.dart';
import '../widgets/search_text_field.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.scrollControllers});

  final List<ScrollController> scrollControllers;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<FruitEntity> fruits = [];

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().getBestSellerProducts();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          const CustomHomeAppBar(),
          Padding(
            padding: EdgeInsets.only(right: 16.w, left: 16.w, bottom: 12.h),
            child: const SearchTextFiled(),
          ),
          const CustomSliderView(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            child: CustomSectionHeader(
              sectionName: "best_seller".tr(),
              onTap: () =>
                  PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                    context,
                    settings: const RouteSettings(name: Routes.bestSellerView),
                    screen: BestSellerView(
                      scrollController: widget.scrollControllers[1],
                      fruits: fruits,
                    ),
                    withNavBar: true,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  ),
            ),
          ),
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is GetBestSellerProductsSuccess) {
                fruits = state.fruits;
                log(fruits.length.toString());
                return Expanded(child: FruitsGridView(fruits: fruits));
              } else if (state is GetBestSellerProductsLoading) {
                return const Expanded(
                  child: Skeletonizer(
                    enabled: true,
                    child: FruitsGridView(itemCount: 6),
                  ),
                );
              } else {
                return const Text("error");
              }
            },
          ),
        ],
      ),
    );
  }
}
