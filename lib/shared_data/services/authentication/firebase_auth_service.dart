import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fruit_hub/core/helpers/app_logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../features/auth/data/models/user_model.dart';
import '../../../features/auth/domain/entities/user_entity.dart';
import '../../../core/helpers/firebase_keys.dart';
import '../../../core/services/authentication/auth_service.dart';

class FirebaseAuthService implements AuthService, SignOutService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  FirebaseAuthService(this._auth, this._googleSignIn, this._facebookAuth);

  @override
  Future<UserEntity> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _returnUserEntity(credential);
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _returnUserEntity(credential);
  }

  @override
  Future<UserEntity> googleSignIn() async {
    final User user = await _googleSignInInternal();
    return UserModel.fromFirebaseUser(user).toUserEntity();
  }

  @override
  Future<UserEntity> facebookSignIn() async {
    final User user = await _facebookSignInInternal();
    return UserModel.fromFirebaseUser(user).toUserEntity();
  }

  @override
  Future<void> deleteCurrentUser() async => await _auth.currentUser?.delete();

  @override
  Future<void> forgetPassword(String email) async =>
      await _auth.sendPasswordResetEmail(email: email);

  @override
  Future<void> sendEmailVerification() async =>
      await _auth.currentUser?.sendEmailVerification();

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _googleSignIn.disconnect();
    } catch (e) {}
    try {
      await _googleSignIn.signOut();
    } catch (e) {}
    try {
      await _facebookAuth.logOut();
    } catch (e) {}
  }

  Future<User> _facebookSignInInternal() async {
    try {
      final LoginResult loginResult = await _facebookAuth.login(
        permissions: ['public_profile', 'email'],
      );

      final accessToken = loginResult.accessToken;
      if (accessToken == null) {
        throw Exception('Facebook access token is null.');
      }
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(accessToken.tokenString);

      final UserCredential signInWithCredential = await _auth
          .signInWithCredential(facebookAuthCredential);

      return _returnUser(signInWithCredential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          final pendingCred = e.credential;
          if (pendingCred == null) {
            rethrow;
          }
          try {
            final User googleUser = await _googleSignInInternal();
            await googleUser.linkWithCredential(pendingCred);
            return googleUser;
          } catch (googleError) {
            throw e;
          }
        default:
          rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User> _googleSignInInternal() async {
    await _googleSignIn.initialize(
      clientId: FirebaseKeys.clientId,
      serverClientId: FirebaseKeys.serverClientId,
    );
    final GoogleSignInAccount? googleUser = await _googleSignIn
        .attemptLightweightAuthentication();

    if (googleUser == null) {
      AppLogger.error("error in google sign in", error: 'No user found');
      throw Exception("The sign-in process was canceled.");
    }

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    if (googleAuth.idToken == null) {
      AppLogger.error(
        "error in google sign in",
        error: 'No idToken received from Google',
      );
      throw Exception(
        "Could not retrieve authentication details from Google. Please try again.",
      );
    }

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    var userCredential = await _auth.signInWithCredential(credential);
    return _returnUser(userCredential);
  }

  User _returnUser(UserCredential userCredential) {
    final user = userCredential.user;
    if (user == null) {
      throw Exception('Firebase user object is null after sign in.');
    }
    return user;
  }

  UserEntity _returnUserEntity(UserCredential credential) {
    final user = credential.user;
    if (user == null) {
      throw Exception('Firebase user object is null after sign in.');
    }
    return UserModel.fromFirebaseUser(user).toUserEntity();
  }
}
