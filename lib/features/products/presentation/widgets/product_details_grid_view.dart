import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product_details_entity.dart';
import 'product_detail_item.dart';

class ProductDetailsGridView extends StatelessWidget {
  const ProductDetailsGridView({super.key, required this.productDetails});

  final List<ProductDetailsEntity> productDetails;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 10.w,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: productDetails
        .map(
          (e) => Expanded(
            child: ProductDetailItem(
              productDetail: e,
              index: productDetails.indexOf(e),
            ),
          ),
        )
        .toList(),
  );
}
