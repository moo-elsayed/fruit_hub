import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';

import '../../domain/entities/notification_entity.dart';

class NotificationItemWidget extends StatelessWidget {
  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationEntity notification;
  final VoidCallback onTap;

  void _handleNavigation(BuildContext context) {
    onTap();

    if (notification.type == 'cart') {
      context.pushNamed(Routes.mainView, arguments: 2);
    } else if (notification.type == 'review' &&
        notification.productCode != null &&
        notification.productCode!.isNotEmpty) {
      context.pushNamed(
        Routes.productDetailsView,
        arguments: notification.productCode,
      );
    }
  }

  IconData _getTypeIcon() => switch (notification.type) {
    'order' => Icons.local_shipping_outlined,
    'cart' => Icons.shopping_cart_outlined,
    'review' => Icons.star_outline_rounded,
    _ => Icons.notifications_none_rounded,
  };

  String _formatTimestamp(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just_now'.tr();
    } else if (difference.inHours < 1) {
      return 'minute_ago'.tr();
    } else if (difference.inDays < 1) {
      return 'hour_ago'.tr();
    } else if (difference.inDays < 7) {
      return 'day_ago'.tr();
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => _handleNavigation(context),
    borderRadius: BorderRadius.circular(16.r),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: notification.isRead
            ? context.colors.surface
            : context.colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: notification.isRead
              ? context.colors.border.withValues(alpha: 0.5)
              : context.colors.primary.withValues(alpha: 0.25),
          width: 1.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.w,
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: notification.isRead
                  ? context.colors.border.withValues(alpha: 0.2)
                  : context.colors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTypeIcon(),
              size: 22.r,
              color: notification.isRead
                  ? context.colors.subText
                  : context.colors.primary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4.h,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.font14Bold.copyWith(
                          color: context.colors.mainText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: BoxDecoration(
                          color: context.colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                Text(
                  notification.body,
                  style: AppTextStyles.font13Regular.copyWith(
                    color: context.colors.subText,
                    height: 1.4,
                  ),
                ),
                if (notification.createdAt != null)
                  Text(
                    _formatTimestamp(notification.createdAt),
                    style: AppTextStyles.font12Regular.copyWith(
                      color: context.colors.subText.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
