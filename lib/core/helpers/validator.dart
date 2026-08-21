import 'package:fruit_hub/core/helpers/app_strings.dart';

class Validator {
  Validator._();

  static String? validateEmail(String? val) {
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    if (val == null || val.trim().isEmpty) {
      return AppStrings.emailCannotBeEmpty;
    } else if (!emailRegex.hasMatch(val)) {
      return AppStrings.enterAValidEmailAddress;
    }
    return null;
  }

  // General use
  static String? validateRequiredField(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    return null;
  }

  static String? validateOldPassword(String? val) {
    if (val == null || val.isEmpty) {
      return AppStrings.passwordCannotBeEmpty;
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

    if (!RegExp(r'(?=.*[A-Z])').hasMatch(val)) {
      return AppStrings.passwordMustContainUppercase;
    }

    if (!RegExp(r'(?=.*[a-z])').hasMatch(val)) {
      return AppStrings.passwordMustContainLowercase;
    }

    if (!RegExp(r'(?=.*\d)').hasMatch(val)) {
      return AppStrings.passwordMustContainNumber;
    }

    if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>_])').hasMatch(val)) {
      return AppStrings.passwordMustContainSpecialCharacter;
    }

    return null;
  }

  static String? validateConfirmPassword(String? val, String? password) {
    if (val == null || val.isEmpty) {
      return AppStrings.passwordCannotBeEmpty;
    } else if (val != password) {
      return AppStrings.confirmPasswordMustMatchThePassword;
    }
    return null;
  }

  static String? validateName(String? val) {
    if (val == null || val.isEmpty) {
      return AppStrings.nameCannotBeEmpty;
    }
    return null;
  }

  static String? validateProfilePicture(String? val) {
    if (val == null || val.isEmpty) {
      return AppStrings.profilePictureIsRequired;
    }
    return null;
  }

  static String? validateNationalIdCardImage(String? val) {
    if (val == null || val.isEmpty) {
      return AppStrings.idCardImageIsRequired;
    }
    return null;
  }

  static String? validateUserName(String? val) {
    if (val == null || val.isEmpty) {
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
    if (int.tryParse(val) == null) {
      return AppStrings.itMustBeANumber;
    }
    return null;
  }

  static String? validateFloorNumber(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.floorNumberCannotBeEmpty;
    }
    if (int.tryParse(val) == null) {
      return AppStrings.itMustBeANumber;
    }
    return null;
  }

  static String? validateApartmentNumber(String? val) {
    if (val == null || val.trim().isEmpty) {
      return AppStrings.apartmentNumberCannotBeEmpty;
    }
    if (int.tryParse(val) == null) {
      return AppStrings.itMustBeANumber;
    }
    return null;
  }

  static String? validateDescription(String? val) {
    if (val == null || val.isEmpty) {
      return AppStrings.pleaseEnterDescription;
    }
    return null;
  }

  static String? validateLocation(String? val) {
    if (val == null || val.isEmpty) {
      return AppStrings.pleaseSelectLocation;
    }
    return null;
  }

  static String? validateDate(String? val) {
    if (val == null || val.isEmpty) {
      return AppStrings.pleaseSelectDate;
    }
    return null;
  }

  static String? validateTime(String? val) {
    if (val == null || val.isEmpty) {
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
    final isValid = RegExp(r'^\+?\d+$').hasMatch(phone);
    if (!isValid) {
      return AppStrings.enterAValidPhoneNumber;
    }

    return null;
  }

  static String? validateCode(String? val) {
    if (val == null || val.isEmpty) {
      return AppStrings.codeCannotBeEmpty;
    } else if (val.length < 6) {
      return AppStrings.codeShouldBeAtLeast6Digits;
    } else {
      return null;
    }
  }

  static String? validateNationalId(String? val) {
    if (val == null || val.isEmpty) {
      return AppStrings.nationalIdCannotBeEmpty;
    } else if (val.length != 14) {
      return AppStrings.nationalIdMustBe14Digits;
    } else {
      return null;
    }
  }
}
