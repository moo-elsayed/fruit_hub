import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/helpers/simple_bloc_observer.dart';
import 'package:fruit_hub/core/routing/app_router.dart';
import 'package:fruit_hub/core/services/notifications/notification_service.dart';
import 'package:fruit_hub/env.dart';
import 'package:fruit_hub/fruit_hub.dart';

import 'firebase_options.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Bloc.observer = SimpleBlocObserver();
  Stripe.publishableKey = Env.stripePublishableKey;

  await Future.wait([
    EasyLocalization.ensureInitialized(),
    ScreenUtil.ensureScreenSize(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  setupServiceLocator();
  await getIt.allReady();
  await getIt<NotificationService>().init();

  runApp(
    EasyLocalization(
      supportedLocales: [const Locale('ar'), const Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      saveLocale: true,
      startLocale: const Locale('ar'),
      child: FruitHub(appRouter: AppRouter()),
    ),
  );
}
