import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/fruits_grid_view.dart';
import 'package:fruit_hub/core/widgets/search_text_field.dart';
import 'package:fruit_hub/features/home/presentation/managers/home_cubit/home_cubit.dart';
import 'package:fruit_hub/features/home/presentation/widgets/custom_home_app_bar.dart';
import 'package:fruit_hub/features/home/presentation/widgets/custom_section_header.dart';
import 'package:gap/gap.dart';

class Home extends StatefulWidget {
  const Home({super.key});

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
  Widget build(BuildContext context) => Column(
    children: [
      const CustomHomeAppBar(),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Hero(
          tag: 'search_bar_hero_tag',
          child: Material(
            color: Colors.transparent,
            child: SearchTextField(
              readOnly: true,
              onTap: () => context.pushNamed(Routes.searchView),
            ),
          ),
        ),
      ),
      Gap(16.h),
      CustomSectionHeader(
        sectionName: AppStrings.bestSeller,
        onTap: () => context.pushNamed(Routes.productsView),
      ),
      Gap(8.h),
      Expanded(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is GetBestSellerProductsSuccess) {
              fruits = state.fruits;
              return FruitsGridView(fruits: fruits);
            } else if (state is GetBestSellerProductsLoading) {
              return const FruitsGridView(itemCount: 6);
            } else if (state is GetBestSellerProductsFailure) {
              return Center(
                child: Text(
                  state.error,
                  style: TextStyle(color: context.colors.subText),
                ),
              );
            } else {
              return Center(
                child: Text(
                  AppStrings.tryAgainLater,
                  style: TextStyle(color: context.colors.subText),
                ),
              );
            }
          },
        ),
      ),
    ],
  );
}
