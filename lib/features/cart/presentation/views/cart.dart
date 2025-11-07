import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_item.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/products_count.dart';
import 'package:gap/gap.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.only(top: 10.h),
          child: CustomAppBar(title: "cart_app_bar".tr()),
        ),
        Gap(8.h),
        const ProductsCount(count: 4),
        Gap(24.h),
        CartItem(size: size),
      ],
    );
  }
}
