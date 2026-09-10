import 'package:fruit_hub/core/helpers/app_strings.dart';

class Validator {
  Validator._();

  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );
  static final RegExp _uppercaseRegex = RegExp(r'(?=.*[A-Z])');
  static final RegExp _lowercaseRegex = RegExp(r'(?=.*[a-z])');
  static final RegExp _numberRegex = RegExp(r'(?=.*\d)');
  static final RegExp _specialCharRegex = RegExp(
    r'(?=.*[!@#$%^&*(),.?":{}|<>_])',
  );
  static final RegExp _phoneRegex = RegExp(r'^\+?\d+$');

  static String? validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.emailCannotBeEmpty;
    }
    if (!_emailRegex.hasMatch(val.trim())) {
      return AppStrings.enterAValidEmailAddress;
    }
    return null;
  }

  static String? validateRequiredField(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    return null;
  }

  static String? validateOldPassword(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.currentPasswordCannotBeEmpty;
    }
    return null;
  }

  static String? validatePassword(String? val) {
    if (val == null || val.isEmpty) {
      return AppStrings.passwordCannotBeEmpty;
    }
    if (val.length < 8) {
      return AppStrings.passwordMustBeAtLeast8CharactersLong;
    }
    if (!_uppercaseRegex.hasMatch(val)) {
      return AppStrings.passwordMustContainUppercase;
    }
    if (!_lowercaseRegex.hasMatch(val)) {
      return AppStrings.passwordMustContainLowercase;
    }
    if (!_numberRegex.hasMatch(val)) {
      return AppStrings.passwordMustContainNumber;
    }
    if (!_specialCharRegex.hasMatch(val)) {
      return AppStrings.passwordMustContainSpecialCharacter;
    }
    return null;
  }

  static String? validateConfirmPassword(String? val, String? password) {
    if (val == null || val.isEmpty) {
      return AppStrings.passwordCannotBeEmpty;
    }
    if (val != password) {
      return AppStrings.confirmPasswordMustMatchThePassword;
    }
    return null;
  }

  static String? validateName(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.nameCannotBeEmpty;
    }
    return null;
  }

  static String? validateProfilePicture(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.profilePictureIsRequired;
    }
    return null;
  }

  static String? validateNationalIdCardImage(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.idCardImageIsRequired;
    }
    return null;
  }

  static String? validateUserName(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.usernameCannotBeEmpty;
    }
    return null;
  }

  static String? validateStreetName(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.streetNameCannotBeEmpty;
    }
    return null;
  }

  static String? validateCity(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.cityCannotBeEmpty;
    }
    return null;
  }

  static String? validateBuildingNumber(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.buildingNumberCannotBeEmpty;
    }
    return null;
  }

  static String? validateFloorNumber(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.floorNumberCannotBeEmpty;
    }
    return null;
  }

  static String? validateApartmentNumber(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.apartmentNumberCannotBeEmpty;
    }
    return null;
  }

  static String? validateDescription(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.pleaseEnterDescription;
    }
    return null;
  }

  static String? validateLocation(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.pleaseSelectLocation;
    }
    return null;
  }

  static String? validateDate(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.pleaseSelectDate;
    }
    return null;
  }

  static String? validateTime(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.pleaseSelectTime;
    }
    return null;
  }

  static String? validateYearOfExperience(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.yearsOfExperienceCannotBeEmpty;
    }
    if (int.tryParse(val) == null) {
      return AppStrings.itMustBeANumber;
    }
    return null;
  }

  static String? validatePhoneNumber(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.phoneNumberCannotBeEmpty;
    }
    final phone = val.trim();
    if (!_phoneRegex.hasMatch(phone)) {
      return AppStrings.enterAValidPhoneNumber;
    }
    return null;
  }

  static String? validateCode(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.codeCannotBeEmpty;
    }
    if (val.trim().length < 6) {
      return AppStrings.codeShouldBeAtLeast6Digits;
    }
    return null;
  }

  static String? validateNationalId(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.nationalIdCannotBeEmpty;
    }
    if (val.trim().length != 14) {
      return AppStrings.nationalIdMustBe14Digits;
    }
    return null;
  }
}
