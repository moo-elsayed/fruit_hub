import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_bottom_sheet_top_container.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/widgets/sort_option_item.dart';
import 'package:gap/gap.dart';

class SortProductsBottomSheet extends StatefulWidget {
  const SortProductsBottomSheet({super.key});

  @override
  State<SortProductsBottomSheet> createState() =>
      _SortProductsBottomSheetState();
}

class _SortProductsBottomSheetState extends State<SortProductsBottomSheet> {
  late int _selectedOption;
  List<String> _sortOptions = [];

  @override
  void initState() {
    super.initState();
    final productsCubit = context.read<ProductsCubit>();
    _sortOptions = productsCubit.sortOptions;
    _selectedOption = productsCubit.selectedSortOption;
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.only(
        topLeft: .circular(24.r),
        topRight: .circular(24.r),
      ),
    ),
    padding: .all(16.h),
    child: Column(
      mainAxisSize: .min,
      children: [
        const CustomBottomSheetTopContainer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'sort_by'.tr(),
              style: AppTextStyles.font19Bold.copyWith(
                color: context.colors.mainText,
              ),
            ),
            if (_selectedOption != -1)
              InkWell(
                onTap: () {
                  context.read<ProductsCubit>().resetSorting();
                  context.pop();
                },
                borderRadius: .circular(8.r),
                child: Padding(
                  padding: .symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    spacing: 4.w,
                    children: [
                      Icon(
                        Icons.restart_alt_rounded,
                        size: 18.sp,
                        color: context.colors.subText,
                      ),
                      Text(
                        'reset'.tr(),
                        style: AppTextStyles.font13SemiBold.copyWith(
                          color: context.colors.subText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        Gap(16.h),
        ...List.generate(
          _sortOptions.length,
          (index) => Padding(
            padding: .only(bottom: index == _sortOptions.length - 1 ? 0 : 12.h),
            child: SortOptionItem(
              onTap: () {
                setState(() {
                  _selectedOption = index;
                });
              },
              isSelected: _selectedOption == index,
              title: _sortOptions[index],
            ),
          ),
        ),
        Gap(32.h),
        CustomMaterialButton(
          onPressed: () {
            final productsCubit = context.read<ProductsCubit>();
            if (_selectedOption != productsCubit.selectedSortOption) {
              context.read<ProductsCubit>().sortProducts(_selectedOption);
            }
            context.pop();
          },
          text: 'apply'.tr(),
          maxWidth: true,
          textStyle: AppTextStyles.font16Bold.copyWith(color: Colors.white),
        ),
      ],
    ),
  );
}
