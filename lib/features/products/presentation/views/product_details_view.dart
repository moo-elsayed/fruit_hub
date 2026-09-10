import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/products/domain/entities/product_details_entity.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../widgets/product_details_bottom_bar.dart';
import '../widgets/product_details_grid_view.dart';
import '../widgets/product_details_header.dart';
import '../widgets/product_details_info_section.dart';

class ProductDetailsView extends StatefulWidget {
  const ProductDetailsView({super.key, this.fruitEntity, this.fruitCode});

  final FruitEntity? fruitEntity;
  final String? fruitCode;

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  final ValueNotifier<int> _quantityNotifier = ValueNotifier<int>(1);

  @override
  void initState() {
    super.initState();
    final code = widget.fruitCode ?? widget.fruitEntity?.code;
    if (code != null) {
      context.read<ProductsCubit>().getProductDetails(code);
    }
  }

  @override
  void dispose() {
    _quantityNotifier.dispose();
    super.dispose();
  }

  void _onAddToCart(FruitEntity fruit) {
    final cartCubit = context.read<CartCubit>();
    final quantity = _quantityNotifier.value;
    cartCubit.addItemToCart(fruit, quantity: quantity);
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          FruitEntity? currentFruit = widget.fruitEntity;

          if (state is GetProductDetailsSuccess) {
            currentFruit = state.fruit;
          }

          if (state is GetProductDetailsFailure && currentFruit == null) {
            return Scaffold(
              backgroundColor: context.colors.background,
              appBar: CustomAppBar(
                title: AppStrings.productDetails,
                showArrowBack: true,
              ),
              body: Center(
                child: Text(
                  state.error,
                  style: AppTextStyles.font14Medium.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ),
            );
          }

          final isLoading = currentFruit == null;
          final displayFruit = currentFruit ?? FruitEntity.dummy;

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              context.pop(currentFruit);
            },
            child: Skeletonizer(
              enabled: isLoading,
              child: Scaffold(
                backgroundColor: context.colors.background,
                bottomNavigationBar: ProductDetailsBottomBar(
                  fruit: displayFruit,
                  quantityNotifier: _quantityNotifier,
                  onAddToCart:
                      isLoading ? () {} : () => _onAddToCart(displayFruit),
                ),
                body: Column(
                  children: [
                    ProductDetailsHeader(fruit: displayFruit),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16.h,
                          children: [
                            ProductDetailsInfoSection(fruit: displayFruit),
                            ProductDetailsGridView(
                              productDetails: getProductDetails(displayFruit),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}
