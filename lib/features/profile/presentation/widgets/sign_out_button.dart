import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helpers/extentions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/services/authentication/auth_service.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_toasts.dart';
import '../../../../core/widgets/custom_confirmation_dialog.dart';
import '../../../../core/widgets/custom_material_button.dart';
import '../../../auth/presentation/managers/signout_cubit/sign_out_cubit.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignOutCubit, SignOutState>(
      listener: (context, state) {
        if (state is SignOutSuccess) {
          AppToast.showToast(
            context: context,
            title: "logged_out_successfully".tr(),
            type: .success,
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
              title: "log_out_confirmation".tr(),
              textConfirmButton: "ok".tr(),
              textCancelButton: "cancel".tr(),
              onConfirm: () async {
                SignOutService signOutService = context.read<SignOutCubit>();
                signOutService.signOut();
              },
            ),
          );
        },
        text: "sign_out".tr(),
        textStyle: AppTextStyles.font16WhiteBold,
        maxWidth: true,
      ),
    );
  }
}
