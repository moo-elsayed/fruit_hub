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
    spacing: 12.w,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      for (int i = 0; i < productDetails.length; i++) ...[
        Expanded(
          child: ProductDetailItem(productDetail: productDetails[i], index: i),
        ),
      ],
    ],
  );
}
