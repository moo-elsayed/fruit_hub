import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/order_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_empty_state_widget.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

import '../managers/orders_cubit/orders_cubit.dart';
import '../managers/orders_cubit/orders_state.dart';
import 'custom_order_item.dart';

class OrdersViewBody extends StatelessWidget {
  const OrdersViewBody({super.key});

  @override
  Widget build(BuildContext context) => BlocConsumer<OrdersCubit, OrdersState>(
    listener: (context, state) {
      if (state is OrdersFailure) {
        AppToast.show(
          context: context,
          title: state.message,
          type: ToastificationType.error,
        );
      }
      if (state is OrderCancelSuccess) {
        AppToast.show(
          context: context,
          title: AppStrings.orderCancelledSuccessfully,
          type: ToastificationType.success,
        );
      }
      if (state is OrderCancelFailure) {
        AppToast.show(
          context: context,
          title: state.message,
          type: ToastificationType.error,
        );
      }
    },
    builder: (context, state) {
      if (state is OrdersFailure &&
          context.read<OrdersCubit>().currentOrders.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: AppTextStyles.font14Medium.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
        );
      }

      final orders = state is OrdersSuccess
          ? state.orders
          : context.read<OrdersCubit>().currentOrders;

      if (state is OrdersSuccess && orders.isEmpty) {
        return CustomEmptyStateWidget(
          title: AppStrings.noOrdersYet,
          text: AppStrings.noOrdersDescription,
          customIcon: Icon(
            Icons.inventory_2_outlined,
            size: 80.sp,
            color: context.colors.primary.withValues(alpha: 0.6),
          ),
        );
      }

      if (orders.isNotEmpty) {
        return ListView.separated(
          itemCount: orders.length,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          separatorBuilder: (context, index) => Gap(12.h),
          itemBuilder: (context, index) => FadeInUp(
            duration: const Duration(milliseconds: 350),
            delay: Duration(milliseconds: 50 * index.clamp(0, 8)),
            child: CustomOrderItem(orderEntity: orders[index]),
          ),
        );
      }

      return Skeletonizer(
        enabled: true,
        child: ListView.separated(
          itemCount: 3,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          separatorBuilder: (context, index) => Gap(12.h),
          itemBuilder: (context, index) =>
              const CustomOrderItem(orderEntity: OrderEntity(orderId: 100001)),
        ),
      );
    },
  );
}
