import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extentions.dart';
import 'package:fruit_hub/core/widgets/confirmation_dialog.dart';
import 'package:gap/gap.dart';
import 'package:restart_app/restart_app.dart';
import '../../../../core/helpers/functions.dart';
import '../../../../core/theming/app_text_styles.dart';

class ChangeLanguageBottomSheet extends StatelessWidget {
  const ChangeLanguageBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "select_language".tr(),
            style: AppTextStyles.font16color0C0D0DSemiBold,
          ),
          Gap(16.h),
          buildListTile(
            context: context,
            isChecked: isArabic(context),
            title: "العربية",
            langCode: "ar",
          ),
          Divider(endIndent: 16.w, indent: 16.w),
          buildListTile(
            context: context,
            isChecked: !isArabic(context),
            title: "English",
            langCode: "en",
          ),
        ],
      ),
    );
  }

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
        builder: (context) => ConfirmationDialog(
          title: "confirm_language_change".tr(),
          fullText: "app_will_restart".tr(),
          textOkButton: "ok".tr(),
          textCancelButton: "cancel".tr(),
          onTap: () async {
            context.pop();
            await context.setLocale(Locale(langCode));
            Restart.restartApp();
          },
        ),
      );
    },
    visualDensity: VisualDensity.compact,
    title: Text(title, style: AppTextStyles.font13color0C0D0DSemiBold),
    trailing: isChecked ? const Icon(Icons.check, color: Colors.green) : null,
  );
}
