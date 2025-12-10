import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/payment_option.dart';
import '../managers/checkout_cubit/checkout_cubit.dart';

class PaymentBody extends StatefulWidget {
  const PaymentBody({super.key});

  @override
  State<PaymentBody> createState() => _PaymentBodyState();
}

class _PaymentBodyState extends State<PaymentBody> {
  int selectedPaymentOption = -1;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CheckoutCubit>();
    if (cubit.paymentOption != null) {
      selectedPaymentOption = getPaymentOptions(
        cubit.shippingConfig!,
      ).indexWhere((element) => element.option == cubit.paymentOption!.option);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentOptions = getPaymentOptions(
      context.read<CheckoutCubit>().shippingConfig!,
    );
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          "choose_the_payment_method_that_suits_you_best".tr(),
          style: AppTextStyles.font13color0C0D0DBold,
        ),
        ...List.generate(paymentOptions.length, (index) {
          return Padding(
            padding: .only(top: 12.h),
            child: PaymentOption(
              paymentOptionEntity: paymentOptions[index],
              onTap: (paymentOptionEntity) {
                setState(() {
                  selectedPaymentOption = index;
                  context.read<CheckoutCubit>().setPaymentOption(
                    paymentOptionEntity,
                  );
                });
              },
              isSelected: selectedPaymentOption == index,
            ),
          );
        }),
      ],
    );
  }
}
