import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fruit_hub/core/helpers/di.dart';
import 'package:fruit_hub/core/routing/app_router.dart';
import 'package:fruit_hub/env.dart';
import 'package:fruit_hub/fruit_hub.dart';
import 'package:fruit_hub/simple_bloc_observer.dart';

import 'firebase_options.dart';

String? globalInitialLinkProductId;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();
  Stripe.publishableKey = Env.stripePublishableKey;
  await Future.wait([
    EasyLocalization.ensureInitialized(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  setupServiceLocator();
  await getIt.allReady();

  try {
    final uri = await AppLinks().getInitialLink();
    if (uri != null && uri.scheme == 'fruithub' && uri.host == 'product') {
      globalInitialLinkProductId = uri.pathSegments.first;
    }
  } catch (e) {
    debugPrint('Deep Link Error: $e');
  }

  runApp(
    EasyLocalization(
      supportedLocales: [const Locale('ar'), const Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      saveLocale: true,
      child: FruitHub(appRouter: AppRouter()),
    ),
  );
}
