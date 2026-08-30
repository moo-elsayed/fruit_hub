import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_confirmation_dialog.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/features/auth/presentation/managers/signout_cubit/sign_out_cubit.dart';
import 'package:toastification/toastification.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocListener<SignOutCubit, SignOutState>(
        listener: (context, state) {
          if (state is SignOutSuccess) {
            AppToast.show(
              context: context,
              title: AppStrings.loggedOutSuccessfully,
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
          onPressed: () => CustomConfirmationDialog.show(
            context: context,
            title: AppStrings.logOutConfirmation,
            textConfirmButton: AppStrings.ok,
            textCancelButton: AppStrings.cancel,
            onConfirm: () async {
              await context.read<SignOutCubit>().signOut();
            },
          ),
          text: AppStrings.signOut,
          textStyle: AppTextStyles.font16Bold.copyWith(color: AppPalette.white),
          maxWidth: true,
        ),
      );
}
