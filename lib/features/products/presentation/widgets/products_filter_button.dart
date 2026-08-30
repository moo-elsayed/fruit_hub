import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_filter_bottom_sheet.dart';

class ProductsFilterButton extends StatelessWidget {
  const ProductsFilterButton({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProductsCubit, ProductsState>(
        buildWhen: (previous, current) {
          if (previous is GetProductsSuccess && current is GetProductsSuccess) {
            return previous.filter != current.filter;
          }
          return current is GetProductsSuccess || current is GetProductsLoading;
        },
        builder: (context, state) {
          final cubit = context.read<ProductsCubit>();
          final bool isSortActive = cubit.currentFilter.hasActiveSort;

          return GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => BlocProvider.value(
                  value: context.read<ProductsCubit>(),
                  child: const ProductsFilterBottomSheet(),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: isSortActive
                    ? context.colors.primary.withValues(alpha: 0.1)
                    : context.colors.surface,
                border: Border.all(
                  color: isSortActive
                      ? context.colors.primary
                      : context.colors.border,
                ),
              ),
              child: SvgPicture.asset(
                AppAssets.iconsFilter,
                colorFilter: isSortActive
                    ? ColorFilter.mode(context.colors.primary, BlendMode.srcIn)
                    : null,
              ),
            ),
          );
        },
      );
}
