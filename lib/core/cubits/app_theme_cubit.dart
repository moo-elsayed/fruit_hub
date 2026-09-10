import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/local_storage/app_preferences_service.dart';

class AppThemeCubit extends Cubit<ThemeMode> {
  AppThemeCubit(this._appPreferencesService) : super(ThemeMode.system) {
    _loadSavedTheme();
  }

  final AppPreferencesService _appPreferencesService;

  void _loadSavedTheme() {
    final savedTheme = _appPreferencesService.getThemeMode();
    switch (savedTheme) {
      case 'light':
        emit(ThemeMode.light);
      case 'dark':
        emit(ThemeMode.dark);
      case 'system':
      default:
        emit(ThemeMode.system);
    }
  }

  Future<void> changeTheme(ThemeMode themeMode) async {
    emit(themeMode);
    String themeString = 'system';
    if (themeMode == ThemeMode.light) themeString = 'light';
    if (themeMode == ThemeMode.dark) themeString = 'dark';
    await _appPreferencesService.saveThemeMode(themeString);
  }
}
