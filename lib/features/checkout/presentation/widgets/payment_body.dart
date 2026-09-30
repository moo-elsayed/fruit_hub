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
  late final CheckoutCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<CheckoutCubit>();
    _paymentOptions = getPaymentOptions(cubit.shippingConfig, cubit.subtotal);
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
  Widget build(BuildContext context) => Column(
    spacing: 12.h,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        AppStrings.chooseThePaymentMethodThatSuitsYouBest,
        style: AppTextStyles.font16Bold.copyWith(
          color: context.colors.mainText,
        ),
      ),
      ValueListenableBuilder<int>(
        valueListenable: _selectedPaymentOptionNotifier,
        builder: (context, selectedIndex, _) => Column(
          spacing: 10.h,
          children: List.generate(
            _paymentOptions.length,
            (index) => PaymentOption(
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
    ],
  );
}
