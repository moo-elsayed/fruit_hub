import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

bool isArabic(BuildContext context) => context.locale.languageCode == 'ar';

void errorLogger({required String functionName, required String error}) =>
    log('exception in function $functionName $error');

String getErrorMessage(result) =>
    (result.exception as dynamic).message ?? result.exception.toString();

num getPrice(double price) => price.toInt() == price ? price.toInt() : price;
