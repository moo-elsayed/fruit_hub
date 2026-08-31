import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
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
  int selectedPaymentOption = 0;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CheckoutCubit>();
    final options = getPaymentOptions(cubit.shippingConfig);
    final index = options.indexWhere(
      (element) => element.type == cubit.paymentOption.type,
    );
    selectedPaymentOption = index != -1 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();
    final paymentOptions = getPaymentOptions(cubit.shippingConfig);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.chooseThePaymentMethodThatSuitsYouBest,
          style: AppTextStyles.font13Bold.copyWith(
            color: context.colors.mainText,
          ),
        ),
        ...List.generate(
          paymentOptions.length,
          (index) => Padding(
            padding: .only(top: 12.h),
            child: PaymentOption(
              paymentOptionEntity: paymentOptions[index],
              onTap: (paymentOptionEntity) {
                setState(() {
                  selectedPaymentOption = index;
                  cubit.setPaymentOption(paymentOptionEntity);
                });
              },
              isSelected: selectedPaymentOption == index,
            ),
          ),
        ),
      ],
    );
  }
}
