import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/args/address_args.dart';
import 'package:toastification/toastification.dart';
import '../../../../core/helpers/extensions.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_toasts.dart';
import '../../../../core/widgets/custom_material_button.dart';
import '../../../../env.dart';
import '../../data/models/order_model.dart';
import '../../domain/entities/order_entity.dart';
import '../managers/checkout_cubit/checkout_cubit.dart';

class CheckoutButtonBlocConsumer extends StatelessWidget {
  const CheckoutButtonBlocConsumer({
    super.key,
    required this.pageController,
    required this.currentIndex,
    required this.addressArgs,
  });

  final PageController pageController;
  final int currentIndex;
  final AddressArgs addressArgs;

  void _navigateToNextPage() => pageController.nextPage(
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
  );

  String _getButtonText() => switch (currentIndex) {
    0 || 1 => AppStrings.next,
    _ => AppStrings.confirmOrder,
  };

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state is AddOrderSuccess) {
            AppToast.show(
              context: context,
              title: AppStrings.orderPlacedSuccessfully,
              type: ToastificationType.success,
            );
            context.read<CartCubit>().clearCart();
            context.pushNamedAndRemoveUntil(
              Routes.orderSuccessView,
              arguments: context.read<CheckoutCubit>().orderEntity,
              predicate: (route) => false,
            );
          }
          if (state is AddOrderFailure) {
            AppToast.show(
              context: context,
              title: state.errorMessage,
              type: ToastificationType.error,
            );
          }
          if (state is MakePaymentFailure) {
            AppToast.show(
              context: context,
              title: state.errorMessage,
              type: ToastificationType.error,
            );
          }
        },
        builder: (context, state) => CustomMaterialButton(
          onPressed: () {
            final cubit = context.read<CheckoutCubit>();
            if (currentIndex == 0) {
              if (addressArgs.isValid) {
                cubit.setAddress(addressArgs.toEntity());
                _navigateToNextPage();
              }
              return;
            }
            if (currentIndex == 1) {
              _navigateToNextPage();
              return;
            }
            if (currentIndex == 2) {
              if (cubit.paymentOption.type == PaymentMethodType.paypal) {
                _executePaypalPayment(
                  context: context,
                  orderEntity: cubit.orderEntity,
                );
              } else if (cubit.paymentOption.type == PaymentMethodType.card) {
                cubit.makePayment();
              } else {
                cubit.addOrder();
              }
            }
          },
          text: _getButtonText(),
          textStyle: AppTextStyles.font16Bold.copyWith(color: AppPalette.white),
          maxWidth: true,
          isLoading: state is AddOrderLoading || state is MakePaymentLoading,
        ),
      );

  void _executePaypalPayment({
    required BuildContext context,
    required OrderEntity orderEntity,
  }) {
    final orderModel = OrderModel.fromEntity(orderEntity);
    final cubit = context.read<CheckoutCubit>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PaypalCheckoutView(
          sandboxMode: true,
          clientId: Env.paypalClientId,
          secretKey: Env.paypalSecretKey,
          transactions: [orderModel.toPaypalTransaction()],
          note: AppStrings.contactUsForAnyQuestionsOnYourOrder,
          onSuccess: (Map params) async {
            context.pop();
            await cubit.addOrder();
          },
          onError: (error) {
            context.pop();
            AppToast.show(
              context: context,
              title: error.toString(),
              type: ToastificationType.error,
            );
          },
          onCancel: () {
            context.pop();
            AppToast.show(
              context: context,
              title: AppStrings.orderCancelled,
              type: ToastificationType.error,
            );
          },
        ),
      ),
    );
  }
}
