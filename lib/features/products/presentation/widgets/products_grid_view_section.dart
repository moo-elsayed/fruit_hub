import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/widgets/custom_empty_state_widget.dart';
import 'package:fruit_hub/core/widgets/custom_fruit_item.dart';
import 'package:fruit_hub/core/widgets/fruits_grid_view.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:gap/gap.dart';

class ProductsGridViewSection extends StatefulWidget {
  const ProductsGridViewSection({super.key});

  @override
  State<ProductsGridViewSection> createState() =>
      _ProductsGridViewSectionState();
}

class _ProductsGridViewSectionState extends State<ProductsGridViewSection> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      final cubit = context.read<ProductsCubit>();
      if (cubit.hasMore && !cubit.isLoadingMore) {
        cubit.fetchNextPage();
      }
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<ProductsCubit, ProductsState>(
    buildWhen: (previous, current) =>
        current is GetProductsSuccess ||
        current is GetProductsLoading ||
        current is GetProductsFailure,
    builder: (context, state) {
      if (state is GetProductsSuccess) {
        if (state.fruits.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => context.read<ProductsCubit>().refresh(),
            color: context.colors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Gap(60.h),
                CustomEmptyStateWidget(
                  title: AppStrings.noProductsFound,
                  text: AppStrings.noResults,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<ProductsCubit>().refresh(),
          color: context.colors.primary,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 8.h,
                  bottom: state.isLoadingMore ? 8.h : 24.h,
                ),
                sliver: SliverGrid(
                  gridDelegate:
                      FruitsGridView.buildSliverGridDelegateWithFixedCrossAxisCount(),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => CustomFruitItem(
                      key: ValueKey(state.fruits[index].code),
                      fruitEntity: state.fruits[index],
                    ),
                    childCount: state.fruits.length,
                  ),
                ),
              ),
              if (state.isLoadingMore)
                SliverPadding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: CupertinoActivityIndicator(
                        radius: 12.r,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      } else if (state is GetProductsLoading) {
        return FruitsGridView(itemCount: 6, bottomPadding: 24.h);
      } else {
        return Center(
          child: Text(
            AppStrings.tryAgainLater,
            style: TextStyle(color: context.colors.subText),
          ),
        );
      }
    },
  );
}
