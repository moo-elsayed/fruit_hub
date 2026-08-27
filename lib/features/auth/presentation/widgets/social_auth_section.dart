import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:gap/gap.dart';
import 'package:toastification/toastification.dart';
import '../managers/social_sign_in_cubit/social_sign_in_cubit.dart';
import 'or_divider.dart';
import 'social_login_button.dart';

class SocialAuthSection extends StatelessWidget {
  const SocialAuthSection({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const OrDivider(),
      Gap(16.h),
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
        builder: (context, state) => SocialLoginButton(
          onPressed: () => context.read<SocialSignInCubit>().googleSignIn(),
          isLoading: state is GoogleLoading,
          text: AppStrings.signInWithGoogle,
          socialIcon: SvgPicture.asset(AppAssets.iconsGoogleIcon),
        ),
      ),
      Gap(16.h),
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
        builder: (context, state) => SocialLoginButton(
          onPressed: () => context.read<SocialSignInCubit>().facebookSignIn(),
          isLoading: state is FacebookLoading,
          text: AppStrings.signInWithFacebook,
          socialIcon: SvgPicture.asset(AppAssets.iconsFacebookIcon),
        ),
      ),
    ],
  );
}
