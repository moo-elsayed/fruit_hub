import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/enums/payment_method_type.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';

class PaymentMethodIcon extends StatelessWidget {
  const PaymentMethodIcon({super.key, required this.type});

  final PaymentMethodType type;

  @override
  Widget build(BuildContext context) => switch (type) {
    PaymentMethodType.paypal => Image.asset(AppAssets.imagesPaypalIcon),
    PaymentMethodType.card => SvgPicture.asset(AppAssets.svgsCard),
    PaymentMethodType.cash => Image.asset(AppAssets.imagesCash),
  };
}
