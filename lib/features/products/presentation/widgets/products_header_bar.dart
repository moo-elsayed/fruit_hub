import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_filter_button.dart';
import 'package:fruit_hub/features/products/presentation/widgets/products_filter_chips_bar.dart';

class ProductsHeaderBar extends StatelessWidget {
  const ProductsHeaderBar({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    child: Row(
      spacing: 10.w,
      children: [
        const Expanded(child: ProductsFilterChipsBar()),
        const ProductsFilterButton(),
      ],
    ),
  );
}
