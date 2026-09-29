import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/enums/product_category_filter.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/widgets/product_category_filter_chip.dart';

class ProductsFilterChipsBar extends StatelessWidget {
  const ProductsFilterChipsBar({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProductsCubit, ProductsState>(
        buildWhen: (previous, current) {
          if (previous is GetProductsSuccess && current is GetProductsSuccess) {
            return previous.filter.categoryFilter !=
                current.filter.categoryFilter;
          }
          return current is GetProductsSuccess || current is GetProductsLoading;
        },
        builder: (context, state) {
          final cubit = context.read<ProductsCubit>();
          final selectedCategory = cubit.currentFilter.categoryFilter;
          const categories = ProductCategoryFilter.values;

          return SizedBox(
            height: 36.h,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8.w,
                children: categories
                    .map(
                      (category) => ProductCategoryFilterChip(
                        category: category,
                        isSelected: selectedCategory == category,
                        onTap: () => cubit.setCategoryFilter(category),
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        },
      );
}
