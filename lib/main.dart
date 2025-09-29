import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fruit_hub/core/routing/app_router.dart';
import 'package:fruit_hub/fruit_hub.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: [const Locale('ar'), const Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      saveLocale: true,
      child: FruitHub(appRouter: AppRouter()),
    ),
  );
}
