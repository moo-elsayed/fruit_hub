import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

class OrderTimelineConnector extends StatelessWidget {
  const OrderTimelineConnector({super.key, required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 2.h,
      margin: EdgeInsets.only(bottom: 20.h),
      color: isCompleted ? context.colors.primary : context.colors.border,
    ),
  );
}
