import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fruit_hub/core/helpers/failures.dart';
import 'package:fruit_hub/core/helpers/functions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/helpers/firebase_keys.dart';
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
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
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
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
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

  Future<NetworkResponse<UserCredential>> googleSignIn() async {
    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;

      await signIn.signOut();

      await signIn.initialize(
        clientId: FirebaseKeys.clientId,
        serverClientId: FirebaseKeys.serverClientId,
      );
      final GoogleSignInAccount? googleUser = await signIn
          .attemptLightweightAuthentication();

      if (googleUser == null) {
        errorLogger(
          functionName: 'AuthFirebase.googleSignIn',
          error: 'User canceled sign in',
        );
        return NetworkFailure(Exception("user_canceled_sign_in".tr()));
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        errorLogger(
          functionName: 'AuthFirebase.googleSignIn',
          error: 'No idToken received from Google',
        );
        return NetworkFailure(
          Exception("error_occurred_please_try_again".tr()),
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      var userCredential = await _auth.signInWithCredential(credential);
      return NetworkSuccess(userCredential);
    } on FirebaseAuthException catch (e) {
      errorLogger(
        functionName: 'AuthFirebase.googleSignIn',
        error: e.toString(),
      );
      return NetworkFailure(
        Exception(ServerFailure.fromFirebaseException(e).errorMessage),
      );
    } on PlatformException catch (e) {
      errorLogger(
        functionName: 'AuthFirebase.googleSignIn',
        error: e.toString(),
      );
      return NetworkFailure(Exception("error_occurred_please_try_again".tr()));
    } catch (e) {
      errorLogger(
        functionName: 'AuthFirebase.googleSignIn',
        error: e.toString(),
      );
      return NetworkFailure(Exception("error_occurred_please_try_again".tr()));
    }
  }

  Future<NetworkResponse<User>> facebookSignIn() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      // Once signed in, return the UserCredential
      var signInWithCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      return NetworkSuccess(signInWithCredential.user);
    } on FirebaseAuthException catch (e) {
      errorLogger(
        functionName: 'AuthFirebase.facebookSignIn',
        error: e.toString(),
      );
      switch (e.code) {
        case 'account-exists-with-different-credential':
          final pendingCred = e.credential;

          var googleCred = await googleSignIn();

          switch (googleCred) {
            case NetworkSuccess<UserCredential>():
              final userCred = await FirebaseAuth.instance.signInWithCredential(
                googleCred.data!.credential!,
              );
              await userCred.user?.linkWithCredential(pendingCred!);
              return NetworkSuccess(userCred.user);
            case NetworkFailure<UserCredential>():
              return NetworkFailure(googleCred.exception);
          }
        default:
          return NetworkFailure(
            Exception(ServerFailure.fromFirebaseException(e).errorMessage),
          );
      }
    } catch (e) {
      errorLogger(
        functionName: 'AuthFirebase.facebookSignIn',
        error: e.toString(),
      );
      return NetworkFailure(Exception("error_occurred_please_try_again".tr()));
    }
  }

  Future<void> forgetPassword(String email) async =>
      await _auth.sendPasswordResetEmail(email: email);
}
