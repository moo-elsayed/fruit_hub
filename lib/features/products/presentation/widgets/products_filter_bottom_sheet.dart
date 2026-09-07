import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/enums/product_sort_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_bottom_sheet_handle.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_reset_sort_button.dart';
import 'package:fruit_hub/features/products/presentation/widgets/sort_option_item.dart';
import 'package:gap/gap.dart';

class ProductsFilterBottomSheet extends StatefulWidget {
  const ProductsFilterBottomSheet({super.key});

  @override
  State<ProductsFilterBottomSheet> createState() =>
      _ProductsFilterBottomSheetState();
}

class _ProductsFilterBottomSheetState extends State<ProductsFilterBottomSheet> {
  late final ValueNotifier<ProductSortType> _selectedSortNotifier;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProductsCubit>();
    _selectedSortNotifier = ValueNotifier(cubit.currentFilter.sortType);
  }

  @override
  void dispose() {
    _selectedSortNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortOptions = ProductSortType.values
        .where((type) => type != ProductSortType.none)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.all(16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomBottomSheetHandle(),
          Gap(12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.sortBy,
                style: AppTextStyles.font19Bold.copyWith(
                  color: context.colors.mainText,
                ),
              ),
              ValueListenableBuilder<ProductSortType>(
                valueListenable: _selectedSortNotifier,
                builder: (context, selectedSort, _) {
                  if (selectedSort == ProductSortType.none) {
                    return const SizedBox.shrink();
                  }
                  return ProductsResetSortButton(
                    onTap: () {
                      final cubit = context.read<ProductsCubit>();
                      if (cubit.currentFilter.hasActiveSort) {
                        cubit.applyFilter(
                          cubit.currentFilter.copyWith(
                            sortType: ProductSortType.none,
                          ),
                        );
                        context.pop();
                      } else {
                        _selectedSortNotifier.value = ProductSortType.none;
                      }
                    },
                  );
                },
              ),
            ],
          ),
          Gap(16.h),
          ValueListenableBuilder<ProductSortType>(
            valueListenable: _selectedSortNotifier,
            builder: (context, selectedSort, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                sortOptions.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index == sortOptions.length - 1 ? 0 : 10.h,
                  ),
                  child: SortOptionItem(
                    onTap: () => _selectedSortNotifier.value =
                        selectedSort == sortOptions[index]
                        ? ProductSortType.none
                        : sortOptions[index],
                    isSelected: selectedSort == sortOptions[index],
                    title: sortOptions[index].title,
                  ),
                ),
              ),
            ),
          ),
          Gap(24.h),
          CustomMaterialButton(
            onPressed: () {
              final cubit = context.read<ProductsCubit>();
              if (_selectedSortNotifier.value != cubit.currentFilter.sortType) {
                cubit.applyFilter(
                  cubit.currentFilter.copyWith(
                    sortType: _selectedSortNotifier.value,
                  ),
                );
              }
              context.pop();
            },
            text: AppStrings.apply,
            maxWidth: true,
            textStyle: AppTextStyles.font16Bold.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
