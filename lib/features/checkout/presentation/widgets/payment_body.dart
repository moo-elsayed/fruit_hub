import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/payment_option.dart';

class PaymentBody extends StatefulWidget {
  const PaymentBody({super.key});


  @override
  State<PaymentBody> createState() => _PaymentBodyState();
}

class _PaymentBodyState extends State<PaymentBody> {
  int selectedPaymentOption = -1;

  @override
  Widget build(BuildContext context) {
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
              shippingEntity: paymentOptions[index],
              onTap: () {
                setState(() {
                  selectedPaymentOption = index;
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
