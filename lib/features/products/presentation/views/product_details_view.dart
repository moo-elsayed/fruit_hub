import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/features/products/domain/entities/product_details_entity.dart';
import 'package:fruit_hub/features/products/presentation/managers/products_cubit/products_cubit.dart';
import 'package:fruit_hub/features/products/presentation/widgets/custom_products_details_header.dart';
import 'package:fruit_hub/features/products/presentation/widgets/product_details_grid_view.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_material_button.dart';
import '../../../../core/widgets/price_per_kilo.dart';
import '../../../cart/presentation/managers/cart_cubit/cart_cubit.dart';

class ProductDetailsView extends StatefulWidget {
  const ProductDetailsView({super.key, this.fruitEntity, this.fruitCode});

  final FruitEntity? fruitEntity;
  final String? fruitCode;

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  @override
  void initState() {
    super.initState();
    if (widget.fruitEntity == null && widget.fruitCode != null) {
      context.read<ProductsCubit>().getProductDetails(widget.fruitCode!);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        FruitEntity? currentFruit = widget.fruitEntity;

        if (state is GetProductDetailsSuccess) {
          currentFruit = state.fruit;
        }

        if (currentFruit != null) {
          return Column(
            children: [
              SizedBox(
                height: 350.h,
                child: CustomProductsDetailsHeader(
                  imagePath: currentFruit.imagePath,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentFruit.name,
                        style: AppTextStyles.font16Bold.copyWith(
                          color: context.colors.mainText,
                        ),
                      ),
                      Gap(4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PricePerKilo(price: currentFruit.price),
                          GestureDetector(
                            onTap: () {
                              log('Go to Reviews Page');
                            },
                            child: Row(
                              children: [
                                Text(
                                  '${currentFruit.avgRating}',
                                  style: AppTextStyles.font13Bold.copyWith(
                                    color: context.colors.primary,
                                  ),
                                ),
                                Gap(4.w),
                                Icon(
                                  Icons.star,
                                  size: 18.sp,
                                  color: Colors.amber,
                                ),
                                Gap(4.w),
                                Text(
                                  'review'.tr(),
                                  style: AppTextStyles.font13Bold.copyWith(
                                    color: context.colors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Gap(8.h),
                      Text(
                        currentFruit.description,
                        style: AppTextStyles.font13Regular.copyWith(
                          color: context.colors.subText,
                        ),
                      ),
                      Expanded(
                        child: ProductDetailsGridView(
                          productDetails: getProductDetails(currentFruit),
                        ),
                      ),
                      CustomMaterialButton(
                        onPressed: () {
                          final myCartService = context.read<CartCubit>();
                          myCartService.addItemToCart(currentFruit!.code);
                        },
                        text: 'add_to_cart'.tr(),
                        textStyle: AppTextStyles.font16Bold.copyWith(
                          color: Colors.white,
                        ),
                        maxWidth: true,
                      ),
                      Gap(16.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else if (state is GetProductDetailsFailure) {
          return Center(child: Text(state.error));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    ),
  );
}
