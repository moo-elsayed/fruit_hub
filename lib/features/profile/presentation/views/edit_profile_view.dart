import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:toastification/toastification.dart';

import '../managers/edit_profile_cubit/edit_profile_cubit.dart';
import '../widgets/edit_profile_view_body.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: AppStrings.editProfile, showArrowBack: true),
    body: BlocListener<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state is EditProfileSuccess) {
          AppToast.show(
            context: context,
            title: AppStrings.profileUpdatedSuccessfully,
            type: ToastificationType.success,
          );
          FocusScope.of(context).unfocus();
        } else if (state is EditProfileFailure) {
          AppToast.show(
            context: context,
            title: state.errorMessage,
            type: ToastificationType.error,
          );
        }
      },
      child: const EditProfileViewBody(),
    ),
  );
}
