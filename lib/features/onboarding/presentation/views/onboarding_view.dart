import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/features/onboarding/presentation/widgets/onboarding_view_body.dart';
import '../managers/onboarding_cubit/onboarding_cubit.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  @override
  Widget build(BuildContext context) => Scaffold(
    body: BlocProvider(
      create: (context) => getIt.get<OnboardingCubit>(),
      child: const OnboardingViewBody(),
    ),
  );
}
