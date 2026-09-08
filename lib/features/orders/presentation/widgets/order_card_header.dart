import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/enums/order_status.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

import 'order_header_badge.dart';

class OrderCardHeader extends StatelessWidget {
  const OrderCardHeader({
    super.key,
    required this.orderId,
    required this.date,
    required this.status,
  });

  final int orderId;
  final String date;
  final OrderStatus status;

  static String _formatDate(String rawDate) {
    if (rawDate.isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
      }
    } catch (_) {}
    return rawDate.length > 10 ? rawDate.substring(0, 10) : rawDate;
  }

  @override
  Widget build(BuildContext context) => Row(
    spacing: 12.w,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          Icons.receipt_long_rounded,
          color: context.colors.primary,
          size: 20.sp,
        ),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 2.h,
          children: [
            Text(
              '${AppStrings.orderNumber} #$orderId',
              style: AppTextStyles.font14Bold.copyWith(
                color: context.colors.mainText,
              ),
            ),
            if (date.isNotEmpty)
              Row(
                spacing: 4.w,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13.sp,
                    color: context.colors.subText,
                  ),
                  Text(
                    _formatDate(date),
                    style: AppTextStyles.font12Regular.copyWith(
                      color: context.colors.subText,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      OrderHeaderBadge(
        label: status.getName,
        color: status.color,
        showDot: true,
      ),
    ],
  );
}
