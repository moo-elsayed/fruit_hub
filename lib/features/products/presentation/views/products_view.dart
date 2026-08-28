import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/fruits_grid_view.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/widgets/sort_products_bottom_sheet.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  List<FruitEntity> fruits = [];

  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().getAllProducts();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: AppStrings.ourProducts,
      showArrowBack: true,
      onTap: () => context.pop(),
    ),
    body: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.products,
                style: AppTextStyles.font16Bold.copyWith(
                  color: context.colors.mainText,
                ),
              ),
              BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  final cubit = context.read<ProductsCubit>();
                  final bool isFilterActive = cubit.selectedSortOption != -1;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.r)),
                      color: isFilterActive
                          ? context.colors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      border: Border.all(
                        color: isFilterActive
                            ? context.colors.primary
                            : context.colors.border,
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
                      child: SvgPicture.asset(AppAssets.iconsFilter),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, state) {
              if (state is GetAllProductsSuccess) {
                fruits = state.fruits;
                return FruitsGridView(fruits: fruits, bottomPadding: 24.h);
              } else if (state is GetAllProductsLoading) {
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
          ),
        ),
      ],
    ),
  );
}
