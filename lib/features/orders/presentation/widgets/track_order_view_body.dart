import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_confirmation_dialog.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/order_timeline_preview.dart';
import 'package:gap/gap.dart';
import 'package:toastification/toastification.dart';

import '../managers/track_order_cubit/track_order_cubit.dart';
import '../managers/track_order_cubit/track_order_state.dart';
import 'order_card_header.dart';
import 'order_customer_details.dart';
import 'order_financial_summary.dart';
import 'order_products_list.dart';

class TrackOrderViewBody extends StatelessWidget {
  const TrackOrderViewBody({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<TrackOrderCubit, TrackOrderState>(
        listener: (context, state) {
          if (state is TrackOrderCancelSuccess) {
            AppToast.show(
              context: context,
              title: AppStrings.orderCancelledSuccessfully,
              type: ToastificationType.success,
            );
          }
          if (state is TrackOrderCancelFailure) {
            AppToast.show(
              context: context,
              title: state.message,
              type: ToastificationType.error,
            );
          }
        },
        builder: (context, state) {
          if (state is TrackOrderLoading &&
              context.read<TrackOrderCubit>().currentOrder == null) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (state is TrackOrderFailure &&
              context.read<TrackOrderCubit>().currentOrder == null) {
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

          final order = state is TrackOrderSuccess
              ? state.order
              : context.read<TrackOrderCubit>().currentOrder;

          if (order == null) {
            return const SizedBox.shrink();
          }

          final isCancelled = order.status == OrderStatus.cancelled;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 300),
                  child: OrderCardHeader(
                    orderId: order.orderId,
                    date: order.date,
                    status: order.status,
                  ),
                ),
                Gap(16.h),
                if (isCancelled)
                  FadeIn(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: AppPalette.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppPalette.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: AppPalette.error,
                            size: 24.sp,
                          ),
                          Gap(12.w),
                          Expanded(
                            child: Text(
                              AppStrings.orderCancelled,
                              style: AppTextStyles.font14Bold.copyWith(
                                color: AppPalette.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  FadeIn(
                    duration: const Duration(milliseconds: 400),
                    child: OrderTimelinePreview(
                      currentStep: order.status.stepIndex,
                    ),
                  ),
                Gap(20.h),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 100),
                  child: OrderCustomerDetails(address: order.shippingAddress),
                ),
                Gap(16.h),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 200),
                  child: OrderProductsList(products: order.orderItems),
                ),
                Gap(16.h),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 300),
                  child: OrderFinancialSummary(
                    subtotal: order.subtotal,
                    shippingCost: order.paymentOption.shippingCost,
                    totalPrice: order.totalPrice,
                  ),
                ),
                if (order.canCancel) ...[
                  Gap(24.h),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 350),
                    child: CustomMaterialButton(
                      onPressed: () => CustomConfirmationDialog.show(
                        context: context,
                        title: AppStrings.cancelOrderConfirm,
                        textConfirmButton: AppStrings.cancelOrder,
                        textCancelButton: AppStrings.cancel,
                        onConfirm: () {
                          context.pop();
                          context.read<TrackOrderCubit>().cancelCurrentOrder();
                        },
                      ),
                      text: AppStrings.cancelOrder,
                      textStyle: AppTextStyles.font14Bold.copyWith(
                        color: AppPalette.error,
                      ),
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(
                        color: AppPalette.error,
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      maxWidth: true,
                      isLoading: state is TrackOrderCancelLoading,
                    ),
                  ),
                ],
                Gap(16.h),
              ],
            ),
          );
        },
      );
}
