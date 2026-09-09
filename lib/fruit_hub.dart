import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/routing/app_router.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/services/notifications/notification_router.dart';
import 'package:fruit_hub/core/theming/app_language_cubit.dart';
import 'package:fruit_hub/core/theming/app_theme.dart';
import 'package:fruit_hub/core/theming/app_theme_cubit.dart';
import 'package:fruit_hub/features/auth/presentation/managers/user_info_cubit/user_info_cubit.dart';
import 'package:toastification/toastification.dart';

class FruitHub extends StatelessWidget {
  const FruitHub({super.key, required this.appRouter});

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt.get<AppThemeCubit>()),
        BlocProvider(create: (context) => getIt.get<AppLanguageCubit>()),
        BlocProvider(create: (context) => getIt.get<UserInfoCubit>()),
      ],
      child: BlocBuilder<AppThemeCubit, ThemeMode>(
        builder: (context, themeMode) => BlocListener<AppLanguageCubit, Locale>(
          listener: (context, locale) => context.setLocale(locale),
          child: ToastificationWrapper(
            child: MaterialApp(
              navigatorKey: NotificationRouter.navigatorKey,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              debugShowCheckedModeBanner: false,
              onGenerateRoute: appRouter.generateRoute,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              initialRoute: Routes.splashView,
            ),
          ),
        ),
      ),
    ),
  );
}
