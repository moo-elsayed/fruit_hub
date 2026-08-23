import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/extensions.dart';

class PaymentMethod extends StatelessWidget {
  const PaymentMethod({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: .symmetric(horizontal: 16.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: .circular(12.r),
    ),
  );
}
