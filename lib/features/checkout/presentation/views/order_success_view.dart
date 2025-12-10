import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: .symmetric(horizontal: 16.w),
        child: Column(
          mainAxisAlignment: .spaceAround,
          crossAxisAlignment: .center,
          children: [
            OrderSuccessTopWidget(orderId: orderEntity.orderId),
            Column(
              spacing: 16.h,
              children: [
                CustomMaterialButton(
                  onPressed: () {},
                  text: "track_order".tr(),
                  maxWidth: true,
                  textStyle: AppTextStyles.font16WhiteBold,
                ),
                GestureDetector(
                  onTap: () => context.pushReplacementNamed(Routes.appSection),
                  child: Text(
                    "home".tr(),
                    style: AppTextStyles.font16color1B5E37EBold.copyWith(
                      decoration: .underline,
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
}
