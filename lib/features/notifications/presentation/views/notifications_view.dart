import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/custom_empty_state_widget.dart';
import 'package:gap/gap.dart';

import '../managers/notifications_cubit/notifications_cubit.dart';
import '../managers/notifications_cubit/notifications_state.dart';
import '../widgets/notifications_list_view.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<NotificationsCubit, NotificationsState>(
    builder: (context, state) {
      final hasUnread = state is NotificationsSuccess && state.unreadCount > 0;

      return Scaffold(
        appBar: CustomAppBar(
          title: AppStrings.notifications,
          showArrowBack: true,
          actions: [
            if (hasUnread)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.read<NotificationsCubit>().markAllAsRead(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: Text(
                    AppStrings.markAllAsRead,
                    style: AppTextStyles.font13Bold.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ),
            Gap(8.w),
          ],
        ),
        body: switch (state) {
          NotificationsLoading() => Center(
            child: CircularProgressIndicator(color: context.colors.primary),
          ),
          NotificationsSuccess(:final notifications)
              when notifications.isNotEmpty =>
            NotificationsListView(notifications: notifications),
          _ => CustomEmptyStateWidget(
            title: AppStrings.noNotifications,
            text: AppStrings.noNotificationsDesc,
            customIcon: Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.iconsNotification,
                  width: 48.r,
                  height: 48.r,
                  colorFilter: ColorFilter.mode(
                    context.colors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        },
      );
    },
  );
}
