import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import '../../../../core/helpers/extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_toasts.dart';
import '../../../../core/widgets/custom_confirmation_dialog.dart';
import '../../../../core/widgets/custom_material_button.dart';
import '../../../auth/presentation/managers/signout_cubit/sign_out_cubit.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocListener<SignOutCubit, SignOutState>(
        listener: (context, state) {
          if (state is SignOutSuccess) {
            AppToast.show(
              context: context,
              title: 'logged_out_successfully'.tr(),
              type: ToastificationType.success,
            );
            context.pushNamedAndRemoveUntil(
              Routes.loginView,
              predicate: (Route<dynamic> route) => false,
              rootNavigator: true,
            );
          }
        },
        child: CustomMaterialButton(
          onPressed: () {
            showCupertinoDialog(
              context: context,
              builder: (_) => CustomConfirmationDialog(
                title: 'log_out_confirmation'.tr(),
                textConfirmButton: 'ok'.tr(),
                textCancelButton: 'cancel'.tr(),
                onConfirm: () async {
                  await context.read<SignOutCubit>().signOut();
                },
              ),
            );
          },
          text: 'sign_out'.tr(),
          textStyle: AppTextStyles.font16Bold.copyWith(color: Colors.white),
          maxWidth: true,
        ),
      );
}
