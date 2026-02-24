import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';

import '../managers/splash_cubit/splash_cubit.dart';
import '../widgets/animated_splash_view_body.dart';

class AnimatedSplashView extends StatelessWidget {
  const AnimatedSplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => SplashCubit(getIt.get<AppPreferencesManager>()),
        child: const AnimatedSplashViewBody(),
      ),
    );
  }
}
