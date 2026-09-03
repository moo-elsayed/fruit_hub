import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/checkout/domain/entities/payment_option_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/managers/checkout_cubit/checkout_cubit.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/payment_option.dart';

class PaymentBody extends StatefulWidget {
  const PaymentBody({super.key});

  @override
  State<PaymentBody> createState() => _PaymentBodyState();
}

class _PaymentBodyState extends State<PaymentBody> {
  late final List<PaymentOptionEntity> _paymentOptions;
  late final ValueNotifier<int> _selectedPaymentOptionNotifier;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CheckoutCubit>();
    _paymentOptions = getPaymentOptions(cubit.shippingConfig);
    final index = _paymentOptions.indexWhere(
      (element) => element.type == cubit.paymentOption.type,
    );
    final initialIndex = index != -1 ? index : 0;
    _selectedPaymentOptionNotifier = ValueNotifier<int>(initialIndex);
    cubit.setPaymentOption(_paymentOptions[initialIndex]);
  }

  @override
  void dispose() {
    _selectedPaymentOptionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.chooseThePaymentMethodThatSuitsYouBest,
          style: AppTextStyles.font13Bold.copyWith(
            color: context.colors.mainText,
          ),
        ),
        ValueListenableBuilder<int>(
          valueListenable: _selectedPaymentOptionNotifier,
          builder: (context, selectedIndex, _) => Column(
            children: List.generate(
              _paymentOptions.length,
              (index) => Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: PaymentOption(
                  paymentOptionEntity: _paymentOptions[index],
                  onTap: (paymentOptionEntity) {
                    _selectedPaymentOptionNotifier.value = index;
                    cubit.setPaymentOption(paymentOptionEntity);
                  },
                  isSelected: selectedIndex == index,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
