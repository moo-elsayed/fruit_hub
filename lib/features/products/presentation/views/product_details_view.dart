import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/products/domain/entities/product_details_entity.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:toastification/toastification.dart';
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
    if (widget.fruitEntity == null && widget.fruitCode != null) {
      context.read<ProductsCubit>().getProductDetails(widget.fruitCode!);
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
  Widget build(BuildContext context) => BlocListener<CartCubit, CartState>(
    listenWhen: (previous, current) =>
        current is CartSuccess || current is CartFailure,
    listener: (context, state) {
      if (state is CartSuccess && state.newItemAdded) {
        AppToast.show(
          context: context,
          title: AppStrings.itemAddedToCart,
          type: ToastificationType.success,
        );
      } else if (state is CartSuccess && state.itemRemoved) {
        AppToast.show(
          context: context,
          title: AppStrings.itemRemovedFromCart,
          type: ToastificationType.success,
        );
      } else if (state is CartFailure) {
        AppToast.show(
          context: context,
          title: state.errorMessage,
          type: ToastificationType.error,
        );
      }
    },
    child: BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        FruitEntity? currentFruit = widget.fruitEntity;

        if (state is GetProductDetailsSuccess) {
          currentFruit = state.fruit;
        }

        if (currentFruit != null) {
          return Scaffold(
            backgroundColor: context.colors.background,
            bottomNavigationBar: ProductDetailsBottomBar(
              fruit: currentFruit,
              quantityNotifier: _quantityNotifier,
              onAddToCart: () => _onAddToCart(currentFruit!),
            ),
            body: Column(
              children: [
                ProductDetailsHeader(fruit: currentFruit),
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
                        ProductDetailsInfoSection(fruit: currentFruit),
                        ProductDetailsGridView(
                          productDetails: getProductDetails(currentFruit),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (state is GetProductDetailsFailure) {
          return Scaffold(
            backgroundColor: context.colors.background,
            body: Center(
              child: Text(
                state.error,
                style: TextStyle(color: context.colors.error),
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: context.colors.background,
            body: Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            ),
          );
        }
      },
    ),
  );
}
