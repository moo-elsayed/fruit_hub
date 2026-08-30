import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/order_success_top_widget.dart';
import '../../domain/entities/order_entity.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key, required this.orderEntity});

  final OrderEntity orderEntity;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OrderSuccessTopWidget(orderId: orderEntity.orderId),
          Column(
            spacing: 16.h,
            children: [
              CustomMaterialButton(
                onPressed: () {},
                text: AppStrings.trackOrder,
                maxWidth: true,
                textStyle: AppTextStyles.font16Bold.copyWith(
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => context.pushReplacementNamed(Routes.mainView),
                child: Text(
                  AppStrings.home,
                  style: AppTextStyles.font16Bold.copyWith(
                    color: context.colors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
