import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/local_storage/app_preferences_service.dart';
import '../services/notifications/notification_service.dart';

class AppLanguageCubit extends Cubit<Locale> {
  AppLanguageCubit({
    required AppPreferencesService preferencesService,
    required this._notificationService,
  }) : _preferencesService = preferencesService,
       super(_resolveInitialLocale(preferencesService));

  final AppPreferencesService _preferencesService;
  final NotificationService _notificationService;

  static Locale _resolveInitialLocale(AppPreferencesService prefs) {
    final lang = prefs.getLanguage();
    return Locale(lang);
  }

  Future<void> changeLanguage(String languageCode) async {
    final locale = Locale(languageCode);
    emit(locale);
    await _preferencesService.saveLanguage(languageCode);
    await _notificationService.updateLanguageCode(languageCode);
  }
}
