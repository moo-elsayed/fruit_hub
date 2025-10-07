import 'package:easy_localization/easy_localization.dart';
import 'app_keys.dart';

abstract class Validator {
  static String? validateEmail(String? val) {
    final RegExp emailRegex = RegExp(AppKeys.emailRegex);
    if (val == null || val.trim().isEmpty) {
      return "email_cannot_be_empty".tr();
    } else if (!emailRegex.hasMatch(val)) {
      return "enter_a_valid_email_address".tr();
    } else {
      return null;
    }
  }

  static String? validatePassword(String? val) {
    if (val == null || val.isEmpty) {
      return "password_cannot_be_empty".tr();
    }

    if (!RegExp(r'^[A-Za-z\d]+$').hasMatch(val)) {
      return "password_must_contain_only_letters_and_numbers".tr();
    }

    if (val.length < 6) {
      return "password_must_be_at_least_6_characters_long".tr();
    }

    if (!RegExp(r'\d').hasMatch(val)) {
      return "password_must_contain_at_least_one_number".tr();
    }

    return null;
  }

  static String? validateConfirmPassword(String? val, String? password) {
    if (val == null || val.isEmpty) {
      return 'Password cannot be empty';
    } else if (val != password) {
      return 'Confirm password must match the password';
    } else {
      return null;
    }
  }

  static String? validateName(String? val) {
    if (val == null || val.isEmpty) {
      return "name_cannot_be_empty".tr();
    } else {
      return null;
    }
  }

  static String? validatePhoneNumber(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Phone number cannot be empty';
    }

    final phone = val.trim();
    final isValid = RegExp(r'^\+?\d+$').hasMatch(phone);
    if (!isValid || phone.length != 13) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  static String? validateCode(String? val) {
    if (val == null || val.isEmpty) {
      return 'Code cannot be empty';
    } else if (val.length < 6) {
      return 'Code should be at least 6 digits';
    } else {
      return null;
    }
  }
}
