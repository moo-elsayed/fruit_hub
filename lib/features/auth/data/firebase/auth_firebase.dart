import 'package:firebase_auth/firebase_auth.dart';
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
      if (e.code == 'user-not-found') {
        return NetworkFailure(Exception('No user found for that email.'));
      } else if (e.code == 'wrong-password') {
        return NetworkFailure(
          Exception('Wrong password provided for that user.'),
        );
      } else {
        return NetworkFailure(Exception(e.code));
      }
    } catch (e) {
      return NetworkFailure(Exception(e.toString()));
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
      if (e.code == 'weak-password') {
        return NetworkFailure(Exception('The password provided is too weak.'));
      } else if (e.code == 'email-already-in-use') {
        return NetworkFailure(
          Exception('The account already exists for that email.'),
        );
      } else {
        return NetworkFailure(Exception(e.code));
      }
    } catch (e) {
      return NetworkFailure(Exception(e.toString()));
    }
  }

  Future<void> sendEmailVerification() async =>
      await _auth.currentUser!.sendEmailVerification();
}
