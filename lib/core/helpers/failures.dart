import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

abstract class Failure {
  Failure(this.errorMessage);

  final String errorMessage;
}

class ServerFailure extends Failure {
  ServerFailure(super.errorMessage);

  factory ServerFailure.fromFirebaseException(FirebaseException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return ServerFailure('invalid_email'.tr());
      case 'wrong-password':
        return ServerFailure("wrong_password_provided_for_that_user".tr());
      case 'user-not-found':
        return ServerFailure("no_user_found_for_that_email".tr());
      case 'user-disabled':
        return ServerFailure('user_disabled'.tr());
      case 'too-many-requests':
        return ServerFailure('too_many_requests'.tr());
      case 'operation-not-allowed':
        return ServerFailure('operation_not_allowed'.tr());
      case 'invalid-credential':
        return ServerFailure("invalid_email_or_password".tr());
      case 'network-request-failed':
        return ServerFailure("network_error_message".tr());
      case 'weak-password':
        return ServerFailure("the_password_provided_is_too_weak".tr());
      case 'email-already-in-use':
        return ServerFailure("the_account_already_exists_for_that_email".tr());
      case 'internal-error':
        return ServerFailure("internal_error".tr());
      case 'app-not-authorized':
        return ServerFailure("app_not_authorized".tr());
      case 'user-token-expired':
        return ServerFailure("user_token_expired".tr());
      case 'requires-recent-login':
        return ServerFailure("requires_recent_login".tr());
      case 'user-mismatch':
        return ServerFailure("user_mismatch".tr());
      case 'quota-exceeded':
        return ServerFailure("quota_exceeded".tr());
      case 'permission-denied':
        return ServerFailure("permission-denied".tr());
      default:
        return ServerFailure("error_occurred_please_try_again".tr());
    }
  }
}
