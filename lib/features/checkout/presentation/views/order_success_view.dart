import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/checkout/domain/entities/order_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_items_preview.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_receipt_card.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_success_top_widget.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_timeline_preview.dart';
import 'package:gap/gap.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key, required this.orderEntity});

  final OrderEntity orderEntity;

  void _navigateToHome(BuildContext context) => context.pushNamedAndRemoveUntil(
    Routes.mainView,
    predicate: (route) => false,
  );

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) {
        _navigateToHome(context);
      }
    },
    child: Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      const OrderSuccessTopWidget(),
                      Gap(20.h),
                      const FadeInUp(
                        duration: Duration(milliseconds: 500),
                        delay: Duration(milliseconds: 100),
                        child: OrderTimelinePreview(),
                      ),
                      Gap(16.h),
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 200),
                        child: OrderReceiptCard(orderEntity: orderEntity),
                      ),
                    ],
                  ),
                ),
                if (orderEntity.products.isNotEmpty) ...[
                  Gap(16.h),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 300),
                    child: OrderItemsPreview(products: orderEntity.products),
                  ),
                ],
                Gap(24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 400),
                    child: CustomMaterialButton(
                      onPressed: () => _navigateToHome(context),
                      text: AppStrings.continueShopping,
                      maxWidth: true,
                      borderRadius: BorderRadius.circular(12.r),
                      icon: Icon(
                        Icons.shopping_bag_outlined,
                        color: AppPalette.white,
                        size: 20.sp,
                      ),
                      textStyle: AppTextStyles.font16Bold.copyWith(
                        color: AppPalette.white,
                      ),
                    ),
                  ),
                ),
                Gap(16.h),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
