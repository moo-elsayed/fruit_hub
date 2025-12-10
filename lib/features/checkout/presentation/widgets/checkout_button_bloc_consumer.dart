import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/services/database/cart_service.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/args/address_args.dart';
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

  List<String> get buttonTexts => [
    "next".tr(),
    "confirm_and_continue".tr(),
    "confirm_order".tr(),
  ];

  void _navigateToNextPage() => pageController.nextPage(
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state is AddOrderSuccess) {
          AppToast.showToast(
            context: context,
            title: "order_placed_successfully".tr(),
            type: .success,
          );
          CartService cartService = context.read<CartCubit>();
          cartService.clearCart();
          context.pushNamedAndRemoveUntil(
            Routes.orderSuccessView,
            arguments: context.read<CheckoutCubit>().orderEntity,
            predicate: (route) => false,
          );
        }
        if (state is AddOrderFailure) {
          AppToast.showToast(
            context: context,
            title: state.errorMessage,
            type: .error,
          );
        }
        if (state is MakePaymentFailure) {
          AppToast.showToast(
            context: context,
            title: state.errorMessage,
            type: .error,
          );
        }
      },
      builder: (context, state) {
        return CustomMaterialButton(
          onPressed: () {
            var cubit = context.read<CheckoutCubit>();
            if (currentIndex == 0 &&
                addressArgs.isValid &&
                cubit.shippingConfig != null) {
              cubit.setAddress(addressArgs.toEntity());
              _navigateToNextPage();
            }
            if (currentIndex == 1) {
              _navigateToNextPage();
            }
            if (currentIndex == 2) {
              if (cubit.paymentOption.type == .paypal) {
                _executePaypalPayment(
                  context: context,
                  orderEntity: cubit.orderEntity,
                );
              } else if (cubit.paymentOption.type == .card) {
                cubit.makePayment();
              } else {
                cubit.addOrder();
              }
            }
          },
          text: buttonTexts[currentIndex],
          textStyle: AppTextStyles.font16WhiteBold,
          maxWidth: true,
          isLoading: state is AddOrderLoading || state is MakePaymentLoading,
        );
      },
    );
  }

  void _executePaypalPayment({
    required BuildContext context,
    required OrderEntity orderEntity,
  }) {
    var orderModel = OrderModel.fromEntity(orderEntity);
    var cubit = context.read<CheckoutCubit>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PaypalCheckoutView(
          sandboxMode: true,
          clientId: Env.paypalClientId,
          secretKey: Env.paypalSecretKey,
          transactions: [orderModel.toPaypalTransaction()],
          note: "contact_us_for_any_questions_on_your_order".tr(),
          onSuccess: (Map params) async {
            context.pop();
            cubit.addOrder();
          },
          onError: (error) {
            context.pop();
            AppToast.showToast(
              context: context,
              title: error.toString(),
              type: .error,
            );
          },
          onCancel: () {
            context.pop();
            AppToast.showToast(
              context: context,
              title: "order_cancelled".tr(),
              type: .error,
            );
          },
        ),
      ),
    );
  }
}
