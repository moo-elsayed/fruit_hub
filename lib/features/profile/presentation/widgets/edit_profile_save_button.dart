import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';

import '../managers/edit_profile_cubit/edit_profile_cubit.dart';

class EditProfileSaveButton extends StatelessWidget {
  const EditProfileSaveButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<EditProfileCubit, EditProfileState>(
        buildWhen: (previous, current) =>
            current is EditProfileLoading ||
            current is EditProfileSuccess ||
            current is EditProfileFailure,
        builder: (context, state) => CustomMaterialButton(
          onPressed: onPressed,
          text: AppStrings.saveChanges,
          isLoading: state is EditProfileLoading,
        ),
      );
}
