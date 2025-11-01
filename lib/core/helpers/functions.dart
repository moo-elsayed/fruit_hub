import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fruit_hub/core/helpers/shared_preferences_manager.dart';
import '../../features/auth/domain/entities/user_entity.dart';

bool isArabic(BuildContext context) => context.locale.languageCode == 'ar';

void errorLogger({required String functionName, required String error}) =>
    log('exception in function $functionName $error');

String getErrorMessage(result) =>
    (result.exception as dynamic).message ?? result.exception.toString();

Future<void> saveUserDataToSharedPreferences(UserEntity entity) async =>
    await Future.wait([
      SharedPreferencesManager.setUsername(entity.name),
      SharedPreferencesManager.setLoggedIn(true),
    ]);

num getPrice(double price) => price.toInt() == price ? price.toInt() : price;
