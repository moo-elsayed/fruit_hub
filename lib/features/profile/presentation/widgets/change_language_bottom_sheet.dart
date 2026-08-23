import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_bottom_sheet_top_container.dart';
import 'package:fruit_hub/core/widgets/custom_confirmation_dialog.dart';
import 'package:gap/gap.dart';
import 'package:restart_app/restart_app.dart';

class ChangeLanguageBottomSheet extends StatelessWidget {
  const ChangeLanguageBottomSheet({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: .symmetric(vertical: 16.h),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.only(
        topLeft: .circular(16.r),
        topRight: .circular(16.r),
      ),
    ),
    child: Column(
      mainAxisSize: .min,
      children: [
        const CustomBottomSheetTopContainer(),
        Text(
          'select_language'.tr(),
          style: AppTextStyles.font16SemiBold.copyWith(
            color: context.colors.mainText,
          ),
        ),
        Gap(16.h),
        buildListTile(
          context: context,
          isChecked: context.isArabic,
          title: 'العربية',
          langCode: 'ar',
        ),
        Divider(color: context.colors.border, endIndent: 16.w, indent: 16.w),
        buildListTile(
          context: context,
          isChecked: !context.isArabic,
          title: 'English',
          langCode: 'en',
        ),
      ],
    ),
  );

  ListTile buildListTile({
    required BuildContext context,
    required String title,
    required bool isChecked,
    required String langCode,
  }) => ListTile(
    onTap: () {
      context.pop();
      showCupertinoDialog(
        context: context,
        builder: (context) => CustomConfirmationDialog(
          title: 'confirm_language_change'.tr(),
          subtitle: 'app_will_restart'.tr(),
          textConfirmButton: 'ok'.tr(),
          textCancelButton: 'cancel'.tr(),
          onConfirm: () async {
            context.pop();
            await context.setLocale(Locale(langCode));
            await Restart.restartApp();
          },
        ),
      );
    },
    visualDensity: .compact,
    title: Text(
      title,
      style: AppTextStyles.font13SemiBold.copyWith(
        color: context.colors.mainText,
      ),
    ),
    trailing: isChecked ? Icon(Icons.check, color: context.colors.primary) : null,
  );
}
