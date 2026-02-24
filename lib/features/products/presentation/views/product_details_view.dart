import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/features/products/domain/entities/product_details_entity.dart';
import 'package:fruit_hub/features/products/presentation/widgets/custom_products_details_header.dart';
import 'package:fruit_hub/features/products/presentation/widgets/product_details_grid_view.dart';
import 'package:gap/gap.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_material_button.dart';
import '../../../../core/widgets/price_per_kilo.dart';
import '../../../cart/presentation/managers/cart_cubit/cart_cubit.dart';

class ProductDetailsView extends StatelessWidget {
  const ProductDetailsView({super.key, required this.fruitEntity});

  final FruitEntity fruitEntity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 350.h,
            child: CustomProductsDetailsHeader(
              imagePath: fruitEntity.imagePath,
            ),
          ),
          Expanded(
            child: Padding(
              padding: .symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: .spaceBetween,
                crossAxisAlignment: .start,
                children: [
                  Text(
                    fruitEntity.name,
                    style: AppTextStyles.font16color0C0D0DBold,
                  ),
                  Gap(4.h),
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      PricePerKilo(price: fruitEntity.price),
                      GestureDetector(
                        onTap: () {
                          log("Go to Reviews Page");
                        },
                        child: Row(
                          children: [
                            Text(
                              "${fruitEntity.avgRating}",
                              style: AppTextStyles.font13color1B5E37Bold,
                            ),
                            Gap(4.w),
                            Icon(
                              Icons.star,
                              size: 18.sp,
                              color: Colors.amber,
                            ),
                            Gap(4.w),
                            Text(
                              "review".tr(),
                              style: AppTextStyles.font13color1B5E37Bold
                                  .copyWith(
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
                    fruitEntity.description,
                    style: AppTextStyles.font13color979899Regular,
                  ),
                  Expanded(
                    child: ProductDetailsGridView(
                      productDetails: getProductDetails(fruitEntity),
                    ),
                  ),
                  CustomMaterialButton(
                    onPressed: () {
                      var myCartService = context.read<CartCubit>();
                      myCartService.addItemToCart(fruitEntity.code);
                    },
                    text: "add_to_cart".tr(),
                    textStyle: AppTextStyles.font16WhiteBold,
                    maxWidth: true,
                  ),
                  Gap(16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
