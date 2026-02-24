import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/theming/app_colors.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/generated/assets.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/widgets/fruits_grid_view.dart';
import '../widgets/sort_products_bottom_sheet.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  List<FruitEntity> fruits = [];

  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().getAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          floating: true,
          snap: true,
          pinned: false,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.white,
          surfaceTintColor: AppColors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: EdgeInsetsGeometry.only(top: 10.h),
              child: CustomAppBar(
                title: "products".tr(),
              ),
            ),
          ),
        ),
        SliverAppBar(
          pinned: true,
          floating: false,
          snap: false,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.white,
          surfaceTintColor: AppColors.white,
          toolbarHeight: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(52.h),
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "our_products".tr(),
                    style: AppTextStyles.font16color0C0D0DBold,
                  ),
                  BlocBuilder<ProductsCubit, ProductsState>(
                    builder: (context, state) {
                      var cubit = context.read<ProductsCubit>();
                      bool isFilterActive = cubit.selectedSortOption != -1;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4.r)),
                          color: isFilterActive
                              ? AppColors.color1B5E37.withValues(alpha: 0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: isFilterActive
                                ? AppColors.color1B5E37
                                : AppColors.colorEAEBEB,
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => BlocProvider.value(
                                value: context.read<ProductsCubit>(),
                                child: const SortProductsBottomSheet(),
                              ),
                            );
                          },
                          child: SvgPicture.asset(Assets.iconsFilter),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          if (state is GetAllProductsSuccess) {
            fruits = state.fruits;
            return FruitsGridView(fruits: fruits);
          } else if (state is GetAllProductsLoading) {
            return const Skeletonizer(
              enabled: true,
              child: FruitsGridView(itemCount: 6),
            );
          } else {
            return const Text("error");
          }
        },
      ),
    );
  }
}
