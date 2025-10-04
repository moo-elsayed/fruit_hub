import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import '../../../../core/helpers/network_response.dart';

class AuthFirebase {
  AuthFirebase._();

  static AuthFirebase? _instance;

  static AuthFirebase get instance => _instance ??= AuthFirebase._();

  final _auth = FirebaseAuth.instance;

  Future<NetworkResponse<User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return NetworkSuccess(credential.user);
    } on FirebaseAuthException catch (e) {
      errorLogger(
        functionName: 'AuthFirebase.signInWithEmailAndPassword',
        error: e.toString(),
      );
      switch (e.code) {
        case 'invalid-credential':
          return NetworkFailure(Exception("invalid_email_or_password".tr()));
        case 'user-not-found':
          return NetworkFailure(Exception("no_user_found_for_that_email".tr()));
        case 'wrong-password':
          return NetworkFailure(
            Exception("wrong_password_provided_for_that_user".tr()),
          );
        case 'network-request-failed':
          return NetworkFailure(Exception("network_error_message".tr()));
        default:
          return NetworkFailure(
            Exception("error_occurred_please_try_again".tr()),
          );
      }
    } catch (e) {
      errorLogger(
        functionName: 'AuthFirebase.signInWithEmailAndPassword',
        error: e.toString(),
      );
      return NetworkFailure(Exception("error_occurred_please_try_again".tr()));
    }
  }

  Future<NetworkResponse<User>> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return NetworkSuccess(credential.user);
    } on FirebaseAuthException catch (e) {
      errorLogger(
        functionName: 'AuthFirebase.createUserWithEmailAndPassword',
        error: e.toString(),
      );
      switch (e.code) {
        case 'weak-password':
          return NetworkFailure(
            Exception("the_password_provided_is_too_weak".tr()),
          );
        case 'email-already-in-use':
          return NetworkFailure(
            Exception("the_account_already_exists_for_that_email".tr()),
          );
        case 'network-request-failed':
          return NetworkFailure(Exception("network_error_message".tr()));
        default:
          return NetworkFailure(
            Exception("error_occurred_please_try_again".tr()),
          );
      }
    } catch (e) {
      errorLogger(
        functionName: 'AuthFirebase.createUserWithEmailAndPassword',
        error: e.toString(),
      );
      return NetworkFailure(Exception("error_occurred_please_try_again".tr()));
    }
  }

  Future<void> sendEmailVerification() async =>
      await _auth.currentUser!.sendEmailVerification();

  Future<void> signOut() async => await _auth.signOut();
}
