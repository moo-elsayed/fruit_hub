import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fruit_hub/core/errors/exceptions.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/network/api_helper.dart';
import 'package:fruit_hub/core/network/network_response.dart';
import 'package:fruit_hub/features/auth/data/models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImp implements AuthRemoteDataSource {
  AuthRemoteDataSourceImp({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FacebookAuth? facebookAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FacebookAuth _facebookAuth;
  static const String _usersCollection = BackendEndpoints.usersCollection;

  @override
  Future<NetworkResponse<UserModel>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async => ApiHelper.executeSafely(() async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw BusinessException(AppStrings.unexpectedError);
      }

      await user.updateDisplayName(username);

      final userModel = UserModel(
        uid: user.uid,
        name: username,
        email: email,
        isVerified: user.emailVerified,
      );

      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(userModel.toJson());

      await user.sendEmailVerification();
      await _firebaseAuth.signOut();

      return userModel;
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') {
        await _firebaseAuth.currentUser?.delete();
      }
      rethrow;
    } catch (_) {
      await _firebaseAuth.currentUser?.delete();
      rethrow;
    }
  }, functionName: 'createUserWithEmailAndPassword');

  @override
  Future<NetworkResponse<UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async => ApiHelper.executeSafely(() async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw BusinessException(AppStrings.userNotFound);
    }

    await user.reload();
    final updatedUser = _firebaseAuth.currentUser ?? user;

    if (!updatedUser.emailVerified) {
      await _firebaseAuth.signOut();
      throw BusinessException(AppStrings.pleaseVerifyYourEmail);
    }

    final userModel = UserModel.fromFirebaseUser(updatedUser);
    return await _getOrUpdateUserFromDB(userModel);
  }, functionName: 'signInWithEmailAndPassword');

  @override
  Future<NetworkResponse<UserModel>> googleSignIn() async =>
      ApiHelper.executeSafely(() async {
        final googleProvider = GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithProvider(
          googleProvider,
        );

        final user = userCredential.user;
        if (user == null) {
          throw BusinessException(AppStrings.unexpectedError);
        }

        final userModel = UserModel.fromFirebaseUser(user);
        return await _getOrUpdateUserFromDB(userModel);
      }, functionName: 'googleSignIn');

  @override
  Future<NetworkResponse<UserModel>> facebookSignIn() async =>
      ApiHelper.executeSafely(() async {
        final LoginResult loginResult = await _facebookAuth.login(
          permissions: ['public_profile', 'email'],
        );

        final accessToken = loginResult.accessToken;
        if (accessToken == null) {
          throw BusinessException('Facebook access token is null.');
        }
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        final UserCredential signInWithCredential = await _firebaseAuth
            .signInWithCredential(facebookAuthCredential);

        final user = signInWithCredential.user;
        if (user == null) {
          throw BusinessException(AppStrings.unexpectedError);
        }

        final userModel = UserModel.fromFirebaseUser(user);
        return await _getOrUpdateUserFromDB(userModel);
      }, functionName: 'facebookSignIn');

  @override
  Future<NetworkResponse<void>> forgetPassword(String email) async =>
      ApiHelper.executeSafely(() async {
        final exists = await _checkIfEmailExists(email);
        if (!exists) {
          throw BusinessException(AppStrings.noUserFoundForThatEmail);
        }
        await _firebaseAuth.sendPasswordResetEmail(email: email);
      }, functionName: 'forgetPassword');

  @override
  Future<NetworkResponse<UserModel>> getUserInfo(String uid) async =>
      ApiHelper.executeSafely(() async {
        final docSnapshot = await _firestore
            .collection(_usersCollection)
            .doc(uid)
            .get();
        if (!docSnapshot.exists || docSnapshot.data() == null) {
          throw BusinessException(AppStrings.userNotFound);
        }
        final data = Map<String, dynamic>.from(docSnapshot.data()!);
        final firebaseUser = _firebaseAuth.currentUser;
        final bool firestoreVerified = data['isVerified'] == true;
        final bool authVerified = firebaseUser?.emailVerified ?? false;
        data['isVerified'] = firestoreVerified || authVerified;
        return UserModel.fromJson(data);
      }, functionName: 'getUserInfo');

  @override
  Future<NetworkResponse<void>> signOut() async =>
      ApiHelper.executeSafely(() async {
        await _firebaseAuth.signOut();
        try {
          await _facebookAuth.logOut();
        } catch (_) {}
      }, functionName: 'signOut');

  // -------------------------------------------------------------------
  // Private Helper Methods
  // -------------------------------------------------------------------

  Future<UserModel> _getOrUpdateUserFromDB(UserModel userModel) async {
    final docSnapshot = await _firestore
        .collection(_usersCollection)
        .doc(userModel.uid)
        .get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      final storedUserData = Map<String, dynamic>.from(docSnapshot.data()!);
      final bool firestoreVerified = storedUserData['isVerified'] == true;
      final bool isVerifiedNow = firestoreVerified || userModel.isVerified;
      storedUserData['isVerified'] = isVerifiedNow;
      await _firestore.collection(_usersCollection).doc(userModel.uid).update({
        'isVerified': isVerifiedNow,
      });
      return UserModel.fromJson(storedUserData);
    } else {
      await _firestore
          .collection(_usersCollection)
          .doc(userModel.uid)
          .set(userModel.toJson());
      return userModel;
    }
  }

  Future<bool> _checkIfEmailExists(String email) async {
    final query = await _firestore
        .collection(_usersCollection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }
}
