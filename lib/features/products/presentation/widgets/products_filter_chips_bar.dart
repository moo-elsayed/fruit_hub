import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/enums/product_category_filter.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';

class ProductsFilterChipsBar extends StatelessWidget {
  const ProductsFilterChipsBar({super.key});

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<ProductsCubit, ProductsState>(
    buildWhen: (previous, current) {
      if (previous is GetProductsSuccess && current is GetProductsSuccess) {
        return previous.filter.categoryFilter != current.filter.categoryFilter;
      }
      return current is GetProductsSuccess || current is GetProductsLoading;
    },
    builder: (context, state) {
      final cubit = context.read<ProductsCubit>();
      final selectedCategory = cubit.currentFilter.categoryFilter;
      const categories = ProductCategoryFilter.values;

      return SizedBox(
        height: 36.h,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (context, index) => SizedBox(width: 8.w),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category;

            return GestureDetector(
              onTap: () => cubit.setCategoryFilter(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  category.label,
                  style: isSelected
                      ? AppTextStyles.font13Bold.copyWith(
                          color: AppPalette.white,
                        )
                      : AppTextStyles.font13Medium.copyWith(
                          color: context.colors.bodyText,
                        ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
