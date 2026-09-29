import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:toastification/toastification.dart';

import '../managers/social_sign_in_cubit/social_sign_in_cubit.dart';
import 'or_divider.dart';

class SocialAuthSection extends StatelessWidget {
  const SocialAuthSection({super.key});

  @override
  Widget build(BuildContext context) => Column(
    spacing: 16.h,
    children: [
      const OrDivider(),
      BlocConsumer<SocialSignInCubit, SocialSignInState>(
        listener: (context, state) {
          if (state is GoogleSuccess) {
            AppToast.show(
              context: context,
              title: AppStrings.welcome,
              type: ToastificationType.success,
            );
            context.pushReplacementNamed(Routes.mainView);
          }
          if (state is GoogleFailure) {
            AppToast.show(
              context: context,
              title: state.message,
              type: ToastificationType.error,
            );
          }
        },
        buildWhen: (previous, current) =>
            current is GoogleSuccess ||
            current is GoogleFailure ||
            current is GoogleLoading,
        builder: (context, state) => CustomMaterialButton(
          onPressed: () => context.read<SocialSignInCubit>().googleSignIn(),
          maxWidth: true,
          backgroundColor: context.colors.surface,
          side: BorderSide(color: context.colors.border),
          isLoading: state is GoogleLoading,
          loadingIndicatorColor: context.colors.primary,
          text: AppStrings.signInWithGoogle,
          textStyle: AppTextStyles.font16SemiBold.copyWith(
            color: context.colors.mainText,
          ),
          icon: SvgPicture.asset(AppAssets.iconsGoogleIcon),
        ),
      ),
      BlocConsumer<SocialSignInCubit, SocialSignInState>(
        listener: (context, state) {
          if (state is FacebookSuccess) {
            AppToast.show(
              context: context,
              title: AppStrings.welcome,
              type: ToastificationType.success,
            );
            context.pushReplacementNamed(Routes.mainView);
          }
          if (state is FacebookFailure) {
            AppToast.show(
              context: context,
              title: state.message,
              type: ToastificationType.error,
            );
          }
        },
        buildWhen: (previous, current) =>
            current is FacebookSuccess ||
            current is FacebookFailure ||
            current is FacebookLoading,
        builder: (context, state) => CustomMaterialButton(
          onPressed: () => context.read<SocialSignInCubit>().facebookSignIn(),
          maxWidth: true,
          backgroundColor: context.colors.surface,
          side: BorderSide(color: context.colors.border),
          isLoading: state is FacebookLoading,
          loadingIndicatorColor: context.colors.primary,
          text: AppStrings.signInWithFacebook,
          textStyle: AppTextStyles.font16SemiBold.copyWith(
            color: context.colors.mainText,
          ),
          icon: SvgPicture.asset(AppAssets.iconsFacebookIcon),
        ),
      ),
    ],
  );
}
