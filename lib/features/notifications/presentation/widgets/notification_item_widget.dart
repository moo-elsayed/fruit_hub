import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/enums/notification_type.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
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

    switch (notification.type) {
      case NotificationType.order:
        if (notification.orderId != null && notification.orderId!.isNotEmpty) {
          context.pushNamed(
            Routes.trackOrderView,
            arguments: notification.orderId,
          );
        }
      case NotificationType.cart:
        context.pushNamed(Routes.mainView, arguments: 2);
      case NotificationType.review:
        if (notification.productCode != null &&
            notification.productCode!.isNotEmpty) {
          context.pushNamed(
            Routes.productDetailsView,
            arguments: notification.productCode,
          );
        }
      case NotificationType.general:
        break;
    }
  }

  String _formatTimestamp(BuildContext context, DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppStrings.justNow;
    } else if (difference.inHours < 1) {
      return AppStrings.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return AppStrings.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return AppStrings.daysAgo(difference.inDays);
    } else {
      return DateFormat(
        'dd/MM/yyyy',
        context.locale.languageCode,
      ).format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _handleNavigation(context),
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
              notification.type.icon,
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
                        notification.localizedTitle(context.isArabic),
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
                  notification.localizedBody(context.isArabic),
                  style: AppTextStyles.font13Regular.copyWith(
                    color: context.colors.subText,
                    height: 1.4,
                  ),
                ),
                if (notification.createdAt != null)
                  Text(
                    _formatTimestamp(context, notification.createdAt),
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
